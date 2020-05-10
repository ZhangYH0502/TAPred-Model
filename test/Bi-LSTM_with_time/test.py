from __future__ import print_function
import tensorflow as tf
import numpy as np 
import os
import scipy
import scipy.io
import h5py
from six.moves import xrange
import math

os.environ['CUDA_VISIBLE_DEVICES']='0'

sample_dim=224
sequence_length=578

hidden_num=256

n_classes=2

def main(argv=None):
    x=tf.placeholder(dtype=tf.float32,shape=[None,sequence_length,sample_dim],name="inputx")
    y=tf.placeholder(dtype=tf.float32,shape=[None,n_classes,1],name="expected_y")
    t=tf.placeholder(dtype=tf.float32,shape=[None,n_classes],name="expected_t")

    x1 = tf.slice(x,[0,0,0],[-1,17*17,-1])
    x2 = tf.slice(x,[0,17*17,0],[-1,17*17,-1])

    t1 = tf.slice(t,[0,0],[-1,1])
    t2 = tf.slice(t,[0,1],[-1,1])

    with tf.variable_scope('lstm'):
        weights=tf.Variable(tf.truncated_normal(shape=[2*hidden_num,n_classes]))
        bias=tf.Variable(tf.zeros(shape=[n_classes]))
        x_1 = tf.transpose(x, [1, 0, 2])
        x_1 = tf.reshape(x_1, [-1, sample_dim])
        x_1 = tf.split(x_1, sequence_length)
        lstm_qx = tf.contrib.rnn.BasicLSTMCell(hidden_num, forget_bias = 1.0)
        lstm_hx = tf.contrib.rnn.BasicLSTMCell(hidden_num, forget_bias = 1.0)
        output, _, _ = tf.contrib.rnn.static_bidirectional_rnn(lstm_qx, lstm_hx, x_1, dtype = tf.float32)
        predy=tf.nn.softmax(tf.matmul(output[-1],weights)+bias,1)
        
        predy_1 = tf.slice(predy,[0,1],[-1,1])
        predy_2 = tf.slice(predy,[0,0],[-1,1])
        predy_1 = predy_1*((t1+t2)/2)
        pred = tf.concat([predy_2,predy_1], -1)
        

    with tf.variable_scope('lstm1',reuse=tf.AUTO_REUSE):
        weights1=tf.Variable(tf.truncated_normal(shape=[2*hidden_num,n_classes]))
        bias1=tf.Variable(tf.zeros(shape=[n_classes]))
        x1_1 = tf.transpose(x1, [1, 0, 2])
        x1_1 = tf.reshape(x1_1, [-1, sample_dim])
        x1_1 = tf.split(x1_1, 17*17)
        lstm_qx1 = tf.contrib.rnn.BasicLSTMCell(hidden_num, forget_bias = 1.0)
        lstm_hx1 = tf.contrib.rnn.BasicLSTMCell(hidden_num, forget_bias = 1.0)
        output1, _, _ = tf.contrib.rnn.static_bidirectional_rnn(lstm_qx1, lstm_hx1, x1_1, dtype = tf.float32)
        predy1=tf.nn.softmax(tf.matmul(output1[-1],weights1)+bias1,1)
        
        predy1_1 = tf.slice(predy1,[0,1],[-1,1])
        predy1_2 = tf.slice(predy1,[0,0],[-1,1])
        predy1_1 = predy1_1*t1
        pred1 = tf.concat([predy1_2,predy1_1], -1)

    with tf.variable_scope('lstm2',reuse=tf.AUTO_REUSE):
        weights2=tf.Variable(tf.truncated_normal(shape=[2*hidden_num,n_classes]))
        bias2=tf.Variable(tf.zeros(shape=[n_classes]))
        x2_1 = tf.transpose(x2, [1, 0, 2])
        x2_1 = tf.reshape(x2_1, [-1, sample_dim])
        x2_1 = tf.split(x2_1, 17*17)
        lstm_qx2 = tf.contrib.rnn.BasicLSTMCell(hidden_num, forget_bias = 1.0)
        lstm_hx2 = tf.contrib.rnn.BasicLSTMCell(hidden_num, forget_bias = 1.0)
        output2, _, _ = tf.contrib.rnn.static_bidirectional_rnn(lstm_qx2, lstm_hx2, x2_1, dtype = tf.float32)
        predy2=tf.nn.softmax(tf.matmul(output2[-1],weights2)+bias2,1)
        
        predy2_1 = tf.slice(predy2,[0,1],[-1,1])
        predy2_2 = tf.slice(predy2,[0,0],[-1,1])
        predy2_1 = predy2_1*t2
        pred2 = tf.concat([predy2_2,predy2_1], -1)
    
    sess = tf.Session()

    print("Setting up Saver...")
    saver = tf.train.Saver()

    sess.run(tf.global_variables_initializer())

    saver.restore(sess, 'logs/model.ckpt-00')
    print("Model restored...")
    
    test_x = np.arange(448*sequence_length*sample_dim).reshape(448,sequence_length,sample_dim)
    test_y = np.arange(448*n_classes*1).reshape(448,n_classes,1)
    time_interval = np.arange(448*2).reshape(448,2)


    filepath = "F:\\zhangyuhan\\GA_tmp\\testing_for_rnn"
    pathDir1 =  os.listdir(filepath)
    
    os.mkdir("F:\\zhangyuhan\\GA_tmp\\rnn_results\\results")
    os.mkdir("F:\\zhangyuhan\\GA_tmp\\rnn_results\\results1")
    os.mkdir("F:\\zhangyuhan\\GA_tmp\\rnn_results\\results2")

    for i in range(448):

        data = h5py.File(filepath+'\\'+str(i+1)+".mat")
        test_x=np.transpose(data['sample'],(2,1,0))

        t1 = np.array(data['time_interval1'])
        t2 = np.array(data['time_interval2'])
        t3 = t1+t2
        t3 = math.exp(t3/(t3+t2))
        t2 = math.exp(t2/(t3+t2))
        time_interval[:,0] = t3
        time_interval[:,1] = t2

        
        scoremap, scoremap1, scoremap2= sess.run([pred,pred1,pred2], feed_dict={x:test_x, y:test_y,t:time_interval})

        scipy.io.savemat(os.path.join("F:\\zhangyuhan\\GA_tmp\\rnn_results\\results\\"+str(i+1)+".mat"), {'scoremap':scoremap})
        scipy.io.savemat(os.path.join("F:\\zhangyuhan\\GA_tmp\\rnn_results\\results1\\"+str(i+1)+".mat"), {'scoremap1':scoremap1})
        scipy.io.savemat(os.path.join("F:\\zhangyuhan\\GA_tmp\\rnn_results\\results2\\"+str(i+1)+".mat"), {'scoremap2':scoremap2})
        

if __name__ == "__main__":
    tf.app.run()
