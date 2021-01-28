import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
from matplotlib.ticker import FormatStrFormatter

from .datasets import sets_flops


GGPLOT_GREEN = "#E24A33"


def plot_fft_flops():

    plt.style.use(["./custom-ggplot.mplstyle", "./matplotlibrc"])

    for name, title, roundtrip, a, data in sets_flops:

        labels = []
        axes = None

        for data_per_lib in data:

            for label, filename, marker, line in data_per_lib:

                data_time  = pd.read_csv(filename.format(      ""), comment=";")
                data_flops = pd.read_csv(filename.format("-flops"), comment=";")
                data = pd.merge(data_time, data_flops, on=["id", "run"])

                if not data["success"].isin(["Warmup", "Success"]).all():
                    raise ValueError(f"Error processing file {file}:\n"
                                     f"Not all runs were Warmup/Success.")

                def max_unary(x): return max(1, x)

                data = data[data["success"] == "Success"]
                data["n"] = data["nx"] \
                          * data["ny"].apply(max_unary) \
                          * data["nz"].apply(max_unary)

                if roundtrip:
                    data["Time_FFT [ms]"]           = data["Time_FFT [ms]"].add(data["Time_iFFT [ms]"])
                    data["FLOPs_transform_forward"] = data["FLOPs_transform_forward"].add(data["FLOPs_transform_backward"])

                data = data[["dim", "n", "Time_FFT [ms]", "FLOPs_transform_forward"]]
                data_grouped = data.groupby(["dim", "n"])

                data_agg = data_grouped.agg({"Time_FFT [ms]":           np.median,
                                             "FLOPs_transform_forward": np.median})
                data_agg.columns = ["runtime", "flops"]
                data_agg.reset_index(level=1, inplace=True)
                data_agg["nldn"] = data_agg["n"].apply(lambda n: a*n*np.log(n))

                axes = data_agg.plot(kind="line", x="n", y="flops", ax=axes, marker=marker, linestyle=line)

                labels += [label]

        axes = data_agg.plot(kind="line", x="n", y="nldn", ax=axes, linestyle="dotted", color=GGPLOT_GREEN)
        labels += [str(a)+"*N*log(N)"]

        axes.set_xscale('log', base=2)
        axes.set_yscale('log', base=10)
        axes.set_xticks(data_agg["n"])

        if not "case1" in name:
            axes.get_xaxis().set_major_formatter(FormatStrFormatter('%d'))

        xmin, xmax = plt.xlim()
        xminNew = 2**(np.log2(xmin)-0.05*np.log2(xmax/xmin))
        xmaxNew = 2**(np.log2(xmax)+0.05*np.log2(xmax/xmin))
        plt.xlim((xminNew, xmaxNew))

        axes.legend(labels)

        plt.title(title)
        plt.xlabel("problem size (# samples)")
        plt.ylabel("# FLOPs")

        plt.savefig(f"plots/fft-flops-{name}.pdf")

        plt.close()

