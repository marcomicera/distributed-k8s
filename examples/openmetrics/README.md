# What is this

In this example, samples from a `cluster_boot` result ([pickle](results.pkl), [csv](results.csv)) 
are converted by a [Jupyter Notebook](https://jupyter.org/) script into a file [`results.prom`](results.prom) which
adopts the [OpenMetrics](https://prometheus.io/docs/instrumenting/exposition_formats/#text-format-details)
file format.

### Steps
1. Start a [Jupyter Notebook](https://jupyter.org/)
    ```bash
    $ jupyter notebook
    ```
1. Run the [`om_writer.ipynb`](om_writer.ipynb) notebook
1. Results are stored in [`results.prom`](results.prom)
