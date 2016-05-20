# LMLiveStreaming
前引：目前直播包含采集端与播放端，播放端目前开源比较好用的是bilibili播放器，网址为https://github.com/Bilibili/ijkplayer，支持了很多的格式，其中包含了RTMP格式，非常的👍

起因：我这里处理的是音视频采集端，目前开源社区比较火的是LiveVideoCoreSDK（https://github.com/search?utf8=✓&q=LiveVideoCore&type=Repositories&ref=searchresults），其中借鉴了videoCore（https://github.com/jgh-/VideoCore），这个外国人写的，但无奈都是C++，ios采集这边目前一般都是SDK，当前我也是借鉴了很多的SDK与VideoCore，写了目前这个LMLiveStreaming。

架构：分为采集－－－>编码--->打包上传  我这边为了更好的扩展，在编码打包以及上传这几个模块通过协议抽象了相关的方法，在滤镜方面用的GPUImage，美颜大家可以参考BeautifyFaceDemo（https://github.com/Guikunzhi/BeautifyFaceDemo）

功能：目前支持FLV上传于RTMP上传，看到映客目前也是支持了2种，上传其中一种在服务器进行转码。支持ios8以上音频视频硬件编码，如果有需要可以反馈（ios7加上软编码），音频为AAC（iphone6s以上采集48K，其余支持44.1K），视频为H264，支持了弱网丢帧，动态的切换码率与分辨率，但是切换分辨率大家一定要小心，因为播放端看着体验不会太好。

目前问题：目前在tcp传输FLV做了断网重连，但RTMP目前没有实现，RTMP传输的延迟比较大，一般为3S到10几秒不等。

近期需要解决：GPUImage实现水印，RTMP断网重连

未来展望：UDP传输，例如RTP，RTSP，或者自己控制重传协议等，还有混音。

服务器搭建： 对于初学直播的同学没有RTMP服务器还真。。。，这里简单介绍一下RTMP＋nginx服务器。
首先下载nginx源码，去nginx.org下载，其次下载nginx-rtmp-module-master（https://github.com/arut/nginx-rtmp-module）代码，再去下载openss（openss.org），然后修改openssl makefile，将PLATFORM=dist改为PLATFORM=darwin64-x86_64-cc，然后cd到nginx源码目录，执行export KERNEL_BITS=64 然后再执行./configure --add-module= nginx-rtmp-module-masterde的路径 --with-openssl= oepnssl源码路径，然后make install.最后查找nginx.conf默认只支持http，添加下面代码再次启动就好了。
rtmp {
    server {
            listen 1935;

        #点播配置
                application vod {
                    play /opt/media/nginxrtmp/flv;
                }
        
        #直播流配置
            application live {
                    live on;
            #为 rtmp 引擎设置最大连接数。默认为 off
            max_connections 1024;

                    # default recorder
                    record all;
                    record_path /var/rec;
 
                    recorder audio {
                         record audio;
                         record_suffix -%d-%b-%y-%T.flv;
                    } 

                    recorder chunked {
                        record all;
                         record_interval 15s;
                         record_path /var/rec/chunked;
                    }

            #on_publish http://localhost:8080/publish;  
            #on_play http://localhost:8080/play;  
            #on_record_done http://localhost:8080/record_done;
            
            #rtmp日志设置
             #access_log logs/rtmp_access.log new;
             #access_log logs/rtmp_access.log;
             #access_log off;

             }
        
        #HLS协议支持
        #application hls {  
            #live on;  
            #hls on;  
            #hls_path /tmp/app;  
            #hls_fragment 5s;  
        #} 

            application hls{
        
                    live on;
                    hls on;
                    hls_path /usr/local/nginx/html/app;
                    hls_fragment 1s;
            }
 

        }
	}



