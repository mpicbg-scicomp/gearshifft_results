import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
from matplotlib.ticker import FormatStrFormatter

from .datasets import sets, sets_smt


NUM_RUNS = 20


def plot_fft_runtime(*args):

    smt  = len(args) > 0 and args[0] == "smt"
    sets_selected = sets_smt if smt else sets

    theme = "ggplot" if smt else "./custom-ggplot.mplstyle"
    plt.style.use([theme, "./matplotlibrc"])

    for name, title, roundtrip, data in sets_selected:

        labels = []
        axes = None

        for data_per_lib in data:

            for label, filename, marker, line in data_per_lib:

                data = pd.read_csv(filename, comment=";")

                if not data["success"].isin(["Warmup", "Success"]).all():
                    raise ValueError(f"Error processing file {file}:\n"
                                     f"Not all runs were Warmup/Success.")

                def max_unary(x): return max(1, x)

                data = data[data["success"] == "Success"]
                data["n"] = data["nx"] \
                        * data["ny"].apply(max_unary) \
                        * data["nz"].apply(max_unary)

                if roundtrip:
                    data["Time_FFT [ms]"] = data["Time_FFT [ms]"].add(data["Time_iFFT [ms]"])

                data = data[["dim", "n", "Time_FFT [ms]"]]
                data_grouped = data.groupby(["dim", "n"])

                def lower(x): return np.quantile(x, 0.25)
                def upper(x): return np.quantile(x, 0.75)
                measures = [lower, np.median, upper]
                data_agg = data_grouped.agg({"Time_FFT [ms]": measures})
                data_agg.columns = ["lower", "median", "upper"]
                data_agg.reset_index(level=1, inplace=True)

                data_agg["upper"] = data_agg["upper"].sub(data_agg["median"])
                data_agg["lower"] = data_agg["median"].sub(data_agg["lower"])
                data_agg.sort_index(inplace=True)

                medians = data_agg[["n", "median"]].set_index("n")
                errors = data_agg[["lower", "upper"]].to_numpy().transpose().reshape(1, 2, -1)

                axes = medians.plot(kind="line", yerr=errors, ax=axes, marker=marker, linestyle=line)

                labels += [label]

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
        plt.ylabel("runtime [ms]")

        plt.savefig(f"plots/fft-runtime-{name}.pdf")

        plt.close()
