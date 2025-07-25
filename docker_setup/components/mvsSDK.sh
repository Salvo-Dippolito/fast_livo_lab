


#Install the mvs_sdk
#.deb file must be downloaded manually somehow
sudo dpkg -i MVS-3.0.1_x86_64_20241128.deb
echo 'export LD_LIBRARY_PATH=/opt/MVS/bin:$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'export PATH=$PATH:/opt/MVS/bin' >> ~/.bashrc


# install the ros mvs package
cd ${ros_src}
git clone --depth 1 --filter=blob:none --no-checkout https://github.com/xuankuzcr/LIV_handhold.git
cd LIV_handhold/
git sparse-checkout init --cone
git sparse-checkout set mvs_ros_pkg
git checkout

mv mvs_ros_pkg ..
cd ..
rm -rf LIV_handhold
cd ..

catkin_make --pkg mvs_ros_pkg

rospack list

catkin_make

sudo ln -s /opt/MVS/bin/MVS /usr/local/bin/MVS


#TODO: take  out login() from grabTrigger.cpp, replace with username