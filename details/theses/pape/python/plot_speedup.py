import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
from matplotlib.ticker import FormatStrFormatter

from .datasets import sets


Y_MIN = -0.1
Y_MAX = 1.3
Y_MAX_COLD = 6.5


def plot_speedup():
    plt.style.use(["./custom-ggplot.mplstyle", "./matplotlibrc"])

    for name, title, roundtrip, data in sets:

        labels  = []
        markers = []
        lines   = []
        table   = None

        for data_per_lib in data:

            for label, filename, marker, line in data_per_lib:

                data = pd.read_csv(filename.format(1), comment=";")

                if not data["success"].isin(["Warmup", "Success"]).all():
                    raise ValueError(f"Error processing file {file}:\n"
                                     f"\tNot all runs were Warmup/Success.")

                def max_unary(x): return max(1, x)

                data = data[data["success"] == "Success"]
                data["n"] = data["nx"] \
                        * data["ny"].apply(max_unary) \
                        * data["nz"].apply(max_unary)

                if roundtrip:
                    data["Time_FFT [ms]"] = data["Time_FFT [ms]"].add(data["Time_iFFT [ms]"])

                data = data[["n", "Time_FFT [ms]"]]
                data_grouped = data.groupby(["n"])

                data_agg = data_grouped.agg(np.median)
                data_agg.columns = [label]
                data_agg.reset_index(level=0, inplace=True)
                data_agg.set_index("n", inplace=True)

                if table is not None:
                    table = pd.merge(table, data_agg, on="n")
                else:
                    table = data_agg

                labels  += [label]
                markers += [marker]
                lines   += [line]

        table = table.div(table["Skylake MKL"], axis=0)
        table = table.applymap(lambda x: 1/x)

        axes = table.plot(kind="line")
        for i, line in enumerate(axes.get_lines()):
            line.set_marker(markers[i])
            line.set_linestyle(lines[i])

        ymax = Y_MAX_COLD if "cold" in name else Y_MAX
        axes.set_xscale('log', base=2)
        axes.set_xticks(table.index)

        if not "case1" in name:
            axes.get_xaxis().set_major_formatter(FormatStrFormatter('%d'))

        xmin, xmax = plt.xlim()
        xminNew = 2**(np.log2(xmin)-0.05*np.log2(xmax/xmin))
        xmaxNew = 2**(np.log2(xmax)+0.05*np.log2(xmax/xmin))
        plt.xlim((xminNew, xmaxNew))
        plt.ylim((Y_MIN, ymax))

        axes.legend(labels, loc="upper left", bbox_to_anchor=(1.0, 1.0))

        plt.title(title)
        plt.xlabel("problem size (# samples)")
        plt.ylabel("performance ratio compared with Skylake")

        plt.savefig(f"plots/fft-speedup-{name}.pdf")

        plt.close()
