from __future__ import print_function
import tensorflow as tf
import numpy as np
import datetime 
import BatchDatsetReader as dataset
import os
import scipy
from six.moves import xrange

os.environ['CUDA_VISIBLE_DEVICES']='1,3'

train_rate=0.00001
MAX_ITERATION=20000+1
batch_size=50

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
        
        cost = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(logits=predy,labels=tf.squeeze(y, squeeze_dims=[2])))
        tf.summary.scalar('loss', cost)
        
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
        
        cost1 = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(logits=predy1,labels=tf.squeeze(y, squeeze_dims=[2])))
        tf.summary.scalar('loss1', cost1)
        
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
        
        cost2 = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(logits=predy2,labels=tf.squeeze(y, squeeze_dims=[2])))
        tf.summary.scalar('loss2', cost2)
    
    train=tf.train.AdamOptimizer(train_rate).minimize(cost)
    train1=tf.train.AdamOptimizer(train_rate).minimize(cost1)
    train2=tf.train.AdamOptimizer(train_rate).minimize(cost2)

    sess = tf.Session()

    print("Setting up Saver...")
    saver = tf.train.Saver()

    sess.run(tf.global_variables_initializer())
    
    
    ckpt = tf.train.get_checkpoint_state("21/")
    if ckpt and ckpt.model_checkpoint_path:
        saver.restore(sess, ckpt.model_checkpoint_path)
        print("Model restored...")
    
    
    print("Setting up dataset reader")
    train_dataset_reader = dataset.BatchDatset('data\\training')
    print(len(train_dataset_reader.path_list))
 
    merged = tf.summary.merge_all()
    writer = tf.summary.FileWriter("logs/", sess.graph)
    for step in xrange(MAX_ITERATION):
        
        batch_x, batch_y, time_interval= train_dataset_reader.next_batch(batch_size)
        
        summary, _, _, _ = sess.run([merged,train,train1,train2],feed_dict={x:batch_x,y:batch_y,t:time_interval})
        
        if step % 100 == 0:
            loss,loss1,loss2 = sess.run([cost,cost1,cost2],feed_dict={x:batch_x,y:batch_y,t:time_interval})
            print("Step: %d, Train_loss:%g, Train_loss1:%g, Train_loss2:%g" % (step, loss, loss1, loss2))
            writer.add_summary(summary,step)
            
            if step % 500 == 0:
                saver.save(sess, "logs/model.ckpt", step)



if __name__ == "__main__":
    tf.app.run()
