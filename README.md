# gearshifft Results and Analysis Tool

## gearshifft Results

The FFT benchmark suite [gearshifft](https://github.com/mpicbg-scicomp/gearshifft) is used to benchmark different FFT libraries on different platforms. 
This repository provides the benchmark results of different combinations as shown in the table below.

| arch | fftw | cufft | clfft |
| --- | --- | --- | --- |
| haswell | 3.3.6pl1 | - | 2.12.2 |
| P100    | - | 8.0.61 | 2.12.2 |
| -       | - | 9.0.69-EA | - |
| GTX1080 | - | 8.0.61 | 2.12.2 |
| K80     | - | 8.0.44 | 2.12.2 |
| K20Xm   | - | 8.0.44 | 2.12.2 |


# R-Shiny Script for R driven gearshifft Data Analysis

The results obtained with [gearshifft](https://github.com/mpicbg-scicomp/gearshifft) can be visualized with our r-shiny app.
`rshiny/app.r` contains R shiny's ui and server functions. `rshiny/helper.r` contains R data processing of gearshifft result files. 

- inspect 1 result file obtained with gearshifft
- inspect 2 result files and compare cross platform or across libraries
- upload your own result file or use results in `results/` provided by gearshifft
- contains plotter, table view and meta information
- various filter settings enable deep analysis of the measurements

## Online R-Shiny App

[**=> Go to the online data analysis tool**!](http://v22017054645049618.nicesrv.de/gearshifft/)

## Local R-Shiny App

Several R libraries are required to run our r-shiny app locally.

```
ggplot2 dplyr plyr readr scales DT shiny
```
After the installation you can run:
```
R -e "shiny::runApp('./app.r')"
```
Afterwards a server is started and you can access the web application via localhost and a given port number.
Things like the port number and errors are shown in the output where the server has been launched.

Note: If you change the helper.r, a simple reload of the web application does not help. rshiny checks only app.r and recaches when app.r has been changed.

## R-Shiny Server (Linux, systemd)

You also can run your own [shiny-server](https://www.rstudio.com/products/shiny/download-server/) application. 
If you run Arch Linux, take this AUR [package](https://aur.archlinux.org/packages/shiny-server-git/).
By the way, With shiny-server it is also possible to host interactive Rmarkdown documents.

Some parts of this guide come from the [admin guide](http://docs.rstudio.com/shiny-server/) and [this howto](http://deanattali.com/2015/05/09/setup-rstudio-shiny-server-digital-ocean/). For SSL, check [this howto](https://qualityandinnovation.com/2015/12/09/deploying-your-very-own-shiny-server/).

Our environment will have one dedicated user called `shiny` for the rshiny apps.


- the gearshifft folder looks like:

```
-rw-rw-r-- 1 shiny shiny 18735 Jul 18 21:09 app.r
-rw-rw-r-- 1 shiny shiny 19561 Jul 18 21:09 helper.r
drwxrwxr-x 6 shiny shiny  4096 Jun  2 18:27 results
drwxrwxr-x 3 shiny shiny  4096 May 23 18:38 www
```

- install R and the packages (global)

```
for i in ggplot2 dplyr plyr readr DT shiny; do
 sudo su - -c "R -q -e \"install.packages('$i', repos='http://cran.rstudio.com/')\""
done
```

- install shiny-server

- configure /etc/shiny-server/shiny-server.conf (see also [the admin guide](http://docs.rstudio.com/shiny-server/#install-shiny) ):

```
server {
  listen 1337;
  run_as shiny;
  members_of shiny-apps;

  location / {
    #sanitize_errors false;
    log_dir /home/shiny/.logs/;

    app_dir /home/shiny/gearshifft/;

    directory_index off;
  }
}
```

- install  nginx and configure /etc/nginx/servers-enabled/default

```
server {
        listen 80 default_server;
        location /gearshifft/ {
                proxy_pass http://127.0.0.1:1337/;
        }
}
```

- start the service

```
systemctl start shiny-server
```

- run nginx

```
systemctl start nginx
```

- test your website `http://.../gearshifft`
