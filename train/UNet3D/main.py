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
MAX_ITERATION = int(1e5*0.2 + 1)
batch_size    = 2
is_training = True

IMG_NUM = 4
HEIGHT = 112
WIDTH = 112

def main(argv=None):
    image = tf.placeholder(tf.float32, shape=[None, IMG_NUM, HEIGHT, WIDTH, 1], name="input_image")
    annotation = tf.placeholder(tf.int32, shape=[None, IMG_NUM, HEIGHT, WIDTH, 1], name="annotation")
    
    pred_annotation, logits = model.unet3d(image, CLASS_NUM)

    if is_training == True:

        loss=tf.reduce_mean((tf.nn.sparse_softmax_cross_entropy_with_logits(logits=logits, labels=tf.squeeze(annotation, squeeze_dims=[4]))))
        tf.summary.scalar('loss', loss)

        train = tf.train.AdamOptimizer(1e-5).minimize(loss)

        print("Setting up dataset reader")
        train_dataset_reader = dataset.BatchDatset('Data_zoo\\training')
        print(len(train_dataset_reader.path_list))
        
    sess = tf.Session()

    print("Setting up Saver...")
    saver = tf.train.Saver()

    print("global_variables_initializer")
    sess.run(tf.global_variables_initializer())

    if is_training == True:

        
        ckpt = tf.train.get_checkpoint_state("logs_21_single_last/")
        if ckpt and ckpt.model_checkpoint_path:
            saver.restore(sess, ckpt.model_checkpoint_path)
            print("Model restored...")
        
            
        merged = tf.summary.merge_all()
        writer = tf.summary.FileWriter("logs/", sess.graph)

        print("begining itr")
        for itr in xrange(MAX_ITERATION):
            train_images, train_annotations = train_dataset_reader.next_batch(batch_size)
            feed_dict = {image: train_images, annotation: train_annotations}

            summary, _=sess.run([merged, train], feed_dict=feed_dict)

            if itr % 500 == 0:
                train_loss = sess.run(loss, feed_dict=feed_dict)
                print("Step: %d, Train_loss:%g" % (itr, train_loss))
                saver.save(sess, "logs/model.ckpt", itr)
                writer.add_summary(summary,itr)
                
    else:     
        ckpt = tf.train.get_checkpoint_state("logs/")
        if ckpt and ckpt.model_checkpoint_path:
            saver.restore(sess, ckpt.model_checkpoint_path)
            print("Model restored...")
        
        # read test image
        test_images = np.arange(1*IMG_NUM*HEIGHT*WIDTH*1).reshape(1,IMG_NUM,HEIGHT,WIDTH,1)
        test_annotations = np.arange(1*IMG_NUM*HEIGHT*WIDTH*1).reshape(1,IMG_NUM,HEIGHT,WIDTH,1)

        filepath = "Data_zoo/testing"
        pathDir =  os.listdir(filepath)
        for allDir in pathDir:
            os.mkdir("Data_zoo/results_112_112"+"/"+allDir)

            print("Step: %s" % (allDir))  
        
            for i in range(16):  
                data = h5py.File(filepath+"/"+allDir+"/"+str(i+1)+".mat")
                test_images[0,:,:,:,0]=np.transpose(np.array(data['sample']),(0,2,1))
               
                pred1, scoremap = sess.run([pred_annotation, logits], feed_dict={image: test_images, annotation: test_annotations})
                pred = pred1[0]
              
                scipy.io.savemat(os.path.join("Data_zoo/results_112_112"+"/"+allDir+"/"+str(i+1)+".mat"), {'pred':pred})


if __name__ == "__main__":
    tf.app.run()
