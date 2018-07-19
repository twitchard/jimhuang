# install s3fs on centos6.8

1. Remove fuse installed by yum

yum remove fuse fuse* fuse-devel
2. Install some dependencies (for both fuse and s3fs-fuse)

yum install automake gcc-c++ git libcurl-devel libxml2-devel make openssl-devel
3. Download and install latest fuse library (version 2.9.7)

cd /usr/local/src
wget https://github.com/libfuse/libfuse/releases/download/fuse-2.9.7/fuse-2.9.7.tar.gz
tar -xzvf fuse-2.9.7.tar.gz
rm -f fuse-2.9.7.tar.gz
mv fuse-2.9.7 fuse
cd fuse/
cd fuse-2.9.7
make clean
./configure --prefix=/usr
make
make install
export PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/lib64/pkgconfig/
ldconfig
4. Test that fuse is installed (should return “2.9.7″)

pkg-config --modversion fuse
5. Install the s3fs-fuse (using the default instructions from github)

git clone https://github.com/s3fs-fuse/s3fs-fuse.git
cd s3fs-fuse
./autogen.sh
./configure
make
sudo make install
6. If there were no errors along the way, this should return the s3fs-fuse version (currently 1.80)

s3fs --version https://geektnt.com/how-to-instal-s3fs-fuse-on-centos-6-8.html

ref: 