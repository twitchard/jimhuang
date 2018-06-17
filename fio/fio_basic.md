# fio basic

## build fio/gfio from source

```sh
git clone https://github.com/axboe/fio.git
sudo apt-get install gtk2.0  # install libgtk2.0-dev
sudo apt-get install libgtk2.0-dev
cd fio
./configure --enable-gfio
make
sudo make install
```

## first-run and the output interpreting

```sh
fio --name first-run --size 1M
```

reference:

[interpreting the output/resut of the 'first-run'][findelkind_fio_output_interpret]

[interpret and understand the fio result/output][findelkind_interpret_fio_output]

[fio output explained][fio_output_explained]

## fio/gfio usage

fio 的　server/client 模式，fio -S 进入 server 模式后会在 8765 tcp 端口上监听，等待客户端 gfio 连接，gfio　连接上后会发送任务，服务端处理任务后将运行结果推送到客户端．

fio -S # 开启 fio 进入 server 模式．fio: server listening on 0.0.0.0,8765
gfio # 另起终端开启客户端 GUI 界面，选择某个 job 文件，连接上服务段发送任务，之后会显示运行图像结果

## fio2gnuplot visualize the output

[fio2gnuplot to visualize the output][findelkind_fio2gnuplot]


## references

fio tester 系列文章
[“fio” Flexible IO Tester post series from installing to a deep dive explanation and usage.][findelkind_fio_tester_post_series]



[findelkind_fio_output_interpret]:http://tfindelkind.com/2015/08/03/fio-flexible-io-tester-appendix-1-interpreting-the-outputresult-of-the-first-run/
[findelkind_fio_tester_post_series]:http://tfindelkind.com/2015/08/04/fio-flexible-io-tester-part1-installation-and-compiling-if-needed/#
[findelkind_interpret_fio_output]:http://tfindelkind.com/2015/08/24/fio-flexible-io-tester-part8-interpret-and-understand-the-resultoutput/
[findelkind_fio2gnuplot]:http://tfindelkind.com/2015/09/16/fio-flexible-io-tester-part9-fio2gnuplot-to-visualize-the-output/
[fio_output_explained]:https://tobert.github.io/post/2014-04-17-fio-output-explained.html