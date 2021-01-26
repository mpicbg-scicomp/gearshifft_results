import json
import numpy as np
import pandas as pd
from matplotlib import pyplot as plt

from .roofline import archs, roofline_files
from .datasets import info_by_case, info_by_arch, sets_by_arch


X_MIN = 2**(-5)
X_MAX = 2**2
Y_MIN = 10**(-3)
Y_MAX = 2000


def rooflines(gflops, bandwidths):
    assert isinstance(bandwidths, list)
    roofs = [([gflops/max(bandwidths), X_MAX], [gflops, gflops])]
    roofs += [([0, gflops/b], [0, gflops]) for b in bandwidths]
    return roofs


def plot_rooflines(*args):

    bare = len(args) > 0 and args[0] == "bare"

    plt.style.use(["./custom-ggplot-roofline.mplstyle", "./matplotlibrc"])

    for arch in archs:

        axes = None
        labels = []
        arm = arch == "Hi1616"

        if not bare:
            for case, sets_by_lib in sets_by_arch[arch].items():

                _, roundtrip, factor_a = info_by_case[case]

                for lib, filename in sets_by_lib.items():

                    marker, = info_by_arch[arch]
                    line = "--" if lib == "FFTW" else "-"
                    label = case + " " + lib

                    data_time  = pd.read_csv(filename.format(""), comment=";")
                    if not arm:
                        data_flops = pd.read_csv(filename.format("-flops"), comment=";")

                    if arm:
                        data = data_time
                    else:
                        data = pd.merge(data_time, data_flops, on=["id", "run"])

                    if not data["success"].isin(["Warmup", "Success"]).all():
                        raise ValueError(f"Error processing file {file}:\n"
                                         f"Not all runs were Warmup/Success.")

                    def max_unary(x): return max(1, x)

                    data = data[data["success"] == "Success"]
                    data["n"] = data["nx"] \
                              * data["ny"].apply(max_unary) \
                              * data["nz"].apply(max_unary)

                    data["precision"] = data["precision"].map(lambda x: 8 if x == "double" else 4)
                    data["complex"]   = data["complex"].map(lambda x: 2 if x == "Complex" else 1)
                    data["bytes"] = 2 * data["n"].mul(data["precision"]).mul(data["complex"])

                    if arm:
                        data["FLOPs_transform_forward"] = data["n"].map(lambda n: factor_a * n * np.log(n))

                    if roundtrip:
                        data["Time_FFT [ms]"]           = data["Time_FFT [ms]"].add(data["Time_iFFT [ms]"])
                        data["bytes"] = 2 * data["bytes"]
                        if arm:
                            data["FLOPs_transform_forward"] = 2 * data["FLOPs_transform_forward"]
                        else:
                            data["FLOPs_transform_forward"] = data["FLOPs_transform_forward"].add(data["FLOPs_transform_backward"])

                    data["gflops_per_sec"] = 10**(-6) * data["FLOPs_transform_forward"].div(data["Time_FFT [ms]"])
                    data["flops_per_byte"] = data["FLOPs_transform_forward"].div(data["bytes"])
                    data = data[["n", "flops_per_byte", "gflops_per_sec"]]
                    data_grouped = data.groupby("n")

                    data_agg = data_grouped.agg({"flops_per_byte": np.median,
                                                 "gflops_per_sec": np.median})

                    axes = data_agg.plot(kind="line", x="flops_per_byte", y="gflops_per_sec", ax=axes, marker=marker, linestyle=line)

                    labels += [label]


        roofline_file = roofline_files[arch]
        with open(roofline_file) as roofline_data_json:
            data = json.load(roofline_data_json)
            gbytes = data["empirical"]["gbytes"]["data"]
            gflops = data["empirical"]["gflops"]["data"]


        bandwidths = []
        bandwidth_labels = []
        for cache_level, bandwidth in gbytes:
            bandwidths.append(bandwidth)
            bandwidth_labels.append(cache_level + " " + str(bandwidth) + "GB/s")

        precision, performance = gflops[0]
        (precision, _) = precision.split()

        rls = rooflines(performance, bandwidths)
        for (xs, ys), l in zip(rls, [str(performance) + " GFLOP/s"]+bandwidth_labels):
            plt.plot(xs, ys, "k")
            x = xs[1]
            y = ys[1]
            offsetX = -8
            offsetY = -1
            ha = "right"
            va = "top"
            rot = 39.5
            if ys[0] == ys[1]:
                offsetX = -1
                offsetY = 0
                va = "bottom"
                rot = "horizontal"
            elif x > X_MAX:
                va = "top"
                rot = "horizontal"
                x = X_MAX
                offsetY = -2
                offsetX = -1

            plt.annotate(l, (x, y), xytext=(offsetX, offsetY), textcoords="offset points",
                         rotation=rot, horizontalalignment=ha, verticalalignment=va,
                         annotation_clip=False)

        axes = plt.gca()
        axes.set_xscale('log', base=2)
        axes.set_yscale('log', base=10)
        axes.set_xlim(xmin=X_MIN, xmax=X_MAX)
        axes.set_ylim(ymin=Y_MIN, ymax=Y_MAX)
        axes.legend(labels, loc="upper left", bbox_to_anchor=(1.0, 1.0))

        plt.title(arch + (" - estimated FLOPs" if arm and not bare else ""))
        plt.xlabel("operational intensity [FLOP/B]")
        plt.ylabel("GFLOP/s")

        name = arch.lower() + ("-bare" if bare else "")
        plt.savefig(f"plots/roofline-{name}.pdf")
        plt.close()
