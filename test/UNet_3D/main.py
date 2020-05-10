from __future__ import print_function

import tensorflow as tf
import numpy as np
import datetime 
import BatchDatsetReader as dataset
import os
import scipy
from six.moves import xrange
import scipy.misc as misc
import scipy.io
import h5py

import model

os.environ['CUDA_VISIBLE_DEVICES']='1'

CLASS_NUM     = 2
MAX_ITERATION = int(1e5*0.5 + 1)
batch_size    = 4

IMG_NUM = 4
HEIGHT = 112
WIDTH = 112

def main(argv=None):
    image = tf.placeholder(tf.float32, shape=[None, IMG_NUM, HEIGHT, WIDTH, 1], name="input_image")
    annotation = tf.placeholder(tf.int32, shape=[None, IMG_NUM, HEIGHT, WIDTH, 1], name="annotation")
    
    pred_annotation, logits = model.unet3d(image, CLASS_NUM)
        
    sess = tf.Session()

    print("Setting up Saver...")
    saver = tf.train.Saver()

    print("global_variables_initializer")
    sess.run(tf.global_variables_initializer())

    saver.restore(sess, 'logs/model.ckpt-00')
    print("Model restored...")
    
    # read test image
    test_images = np.arange(1*IMG_NUM*HEIGHT*WIDTH*1).reshape(1,IMG_NUM,HEIGHT,WIDTH,1)
    test_annotations = np.arange(1*IMG_NUM*HEIGHT*WIDTH*1).reshape(1,IMG_NUM,HEIGHT,WIDTH,1)

    filepath = "F:\\zhangyuhan\\GA_tmp\\testing for 3DUNet"
    
    for i in range(16):  
        data = h5py.File(filepath+"\\"+str(i+1)+".mat")
        test_images[0,:,:,:,0]=np.transpose(np.array(data['sample']),(0,2,1))
       
        pred1, scoremap = sess.run([pred_annotation, logits], feed_dict={image: test_images, annotation: test_annotations})
        pred = pred1[0]
      
        scipy.io.savemat(os.path.join("F:\\zhangyuhan\\GA_tmp\\3DUNet-results\\"+str(i+1)+".mat"), {'pred':pred})


if __name__ == "__main__":
    tf.app.run()
