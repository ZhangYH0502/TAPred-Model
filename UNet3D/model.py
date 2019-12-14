
import tensorflow as tf


def attention(x):
    x_shape = x.get_shape().as_list()
    input_channel = x_shape[-1]
    height = x_shape[2]
    width = x_shape[3]

    pool = tf.nn.avg_pool3d(x, ksize=[1,1,height,width,1], strides=[1,1,1,1,1], padding="VALID")
    dense1 = tf.layers.dense(inputs=pool, units=input_channel, activation=tf.nn.relu)
    dense2 = tf.layers.dense(inputs=dense1, units=input_channel, activation=None)

    sig = tf.nn.sigmoid(dense2)

    return tf.multiply(x, sig)

def multi_resolution_conv(x):
    x_shape = x.get_shape().as_list()
    input_channel = x_shape[-1]

    '''
    W1 = tf.Variable(tf.truncated_normal([3,3,3,input_channel,input_channel], stddev=0.02))
    b1 = tf.Variable(tf.constant(0.0, shape=[input_channel]))
    relu1 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(x, W1, strides=[1, 1, 1, 1, 1], padding="SAME"), b1))
    relu1 = tf.nn.conv3d(relu1, tf.Variable(tf.truncated_normal([1,1,1,input_channel,tf.cast(input_channel/4,dtype=tf.int32)], stddev=0.02)), strides=[1, 1, 1, 1, 1], padding="SAME")
    '''

    W2 = tf.Variable(tf.truncated_normal([5,5,5,input_channel,input_channel], stddev=0.02))
    b2 = tf.Variable(tf.constant(0.0, shape=[input_channel]))
    relu2 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(x, W2, strides=[1, 1, 1, 1, 1], padding="SAME"), b2))
    relu2 = tf.nn.conv3d(relu2, tf.Variable(tf.truncated_normal([1,1,1,input_channel,tf.cast(input_channel/2,dtype=tf.int32)], stddev=0.02)), strides=[1, 1, 1, 1, 1], padding="SAME")

    '''
    W3 = tf.Variable(tf.truncated_normal([7,7,7,input_channel,input_channel], stddev=0.02))
    b3 = tf.Variable(tf.constant(0.0, shape=[input_channel]))
    relu3 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(x, W3, strides=[1, 1, 1, 1, 1], padding="SAME"), b3))
    relu3 = tf.nn.conv3d(relu3, tf.Variable(tf.truncated_normal([1,1,1,input_channel,tf.cast(input_channel/4,dtype=tf.int32)], stddev=0.02)), strides=[1, 1, 1, 1, 1], padding="SAME")
    '''

    W4 = tf.Variable(tf.truncated_normal([9,9,9,input_channel,input_channel], stddev=0.02))
    b4 = tf.Variable(tf.constant(0.0, shape=[input_channel]))
    relu4 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(x, W4, strides=[1, 1, 1, 1, 1], padding="SAME"), b4))
    relu4 = tf.nn.conv3d(relu4, tf.Variable(tf.truncated_normal([1,1,1,input_channel,tf.cast(input_channel/2,dtype=tf.int32)], stddev=0.02)), strides=[1, 1, 1, 1, 1], padding="SAME")

    return tf.concat([x,relu2,relu4], -1)


def unet3d(x, CLASS_NUM):
    
    W1_1 = tf.Variable(tf.truncated_normal([3,3,3,1,32], stddev=0.02))
    b1_1 = tf.Variable(tf.constant(0.0, shape=[32]))
    relu1_1 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(x, W1_1, strides=[1, 1, 1, 1, 1], padding="SAME"), b1_1))
    W1_2 = tf.Variable(tf.truncated_normal([3,3,3,32,64], stddev=0.02))
    b1_2 = tf.Variable(tf.constant(0.0, shape=[64]))
    relu1_2 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(relu1_1, W1_2, strides=[1, 1, 1, 1, 1], padding="SAME"), b1_2))

    #relu1_2 = attention(relu1_2)

    pool1 = tf.nn.max_pool3d(relu1_2, ksize=[1,1,2,2,1], strides=[1,1,2,2,1], padding="SAME")
    print(pool1.shape)

    W2_1 = tf.Variable(tf.truncated_normal([3,3,3,64,64], stddev=0.02))
    b2_1 = tf.Variable(tf.constant(0.0, shape=[64]))
    relu2_1 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(pool1, W2_1, strides=[1, 1, 1, 1, 1], padding="SAME"), b2_1))
    W2_2 = tf.Variable(tf.truncated_normal([3,3,3,64,128], stddev=0.02))
    b2_2 = tf.Variable(tf.constant(0.0, shape=[128]))
    relu2_2 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(relu2_1, W2_2, strides=[1, 1, 1, 1, 1], padding="SAME"), b2_2))

    #relu2_2 = attention(relu2_2)

    pool2 = tf.nn.max_pool3d(relu2_2, ksize=[1,1,2,2,1], strides=[1,1,2,2,1], padding="SAME")
    print(pool2.shape)

    W3_1 = tf.Variable(tf.truncated_normal([3,3,3,128,128], stddev=0.02))
    b3_1 = tf.Variable(tf.constant(0.0, shape=[128]))
    relu3_1 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(pool2, W3_1, strides=[1, 1, 1, 1, 1], padding="SAME"), b3_1))
    W3_2 = tf.Variable(tf.truncated_normal([3,3,3,128,256], stddev=0.02))
    b3_2 = tf.Variable(tf.constant(0.0, shape=[256]))
    relu3_2 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(relu3_1, W3_2, strides=[1, 1, 1, 1, 1], padding="SAME"), b3_2))

    #relu3_2 = attention(relu3_2)
    
    pool3 = tf.nn.max_pool3d(relu3_2, ksize=[1,1,2,2,1], strides=[1,1,2,2,1], padding="SAME")
    print(pool3.shape)

    W4_1 = tf.Variable(tf.truncated_normal([3,3,3,256,256], stddev=0.02))
    b4_1 = tf.Variable(tf.constant(0.0, shape=[256]))
    relu4_1 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(pool3, W4_1, strides=[1, 1, 1, 1, 1], padding="SAME"), b4_1))
    W4_2 = tf.Variable(tf.truncated_normal([3,3,3,256,512], stddev=0.02))
    b4_2 = tf.Variable(tf.constant(0.0, shape=[512]))
    relu4_2 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(relu4_1, W4_2, strides=[1, 1, 1, 1, 1], padding="SAME"), b4_2))

    #relu4_2 = attention(relu4_2)

    pool4 = tf.nn.max_pool3d(relu4_2, ksize=[1,1,2,2,1], strides=[1,1,2,2,1], padding="SAME")
    print(pool4.shape)

    W5_1 = tf.Variable(tf.truncated_normal([3,3,3,512,512], stddev=0.02))
    b5_1 = tf.Variable(tf.constant(0.0, shape=[512]))
    relu5_1 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(pool4, W5_1, strides=[1, 1, 1, 1, 1], padding="SAME"), b5_1))
    W5_2 = tf.Variable(tf.truncated_normal([3,3,3,512,512], stddev=0.02))
    b5_2 = tf.Variable(tf.constant(0.0, shape=[512]))
    relu5_2 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(relu5_1, W5_2, strides=[1, 1, 1, 1, 1], padding="SAME"), b5_2))

    #relu5_2 = attention(relu5_2)

    ################################################

    W_trans1 = tf.Variable(tf.truncated_normal([4,4,4,512,512], stddev=0.02))
    b_trans1 = tf.Variable(tf.constant(0.0, shape=[512]))
    conv_trans1 = tf.nn.bias_add(tf.nn.conv3d_transpose(relu5_2, W_trans1, output_shape = tf.shape(relu4_2), strides=[1, 1, 2, 2, 1], padding="SAME"), b_trans1)
    print(conv_trans1.shape)

    block1 = tf.concat([relu4_2,conv_trans1], -1)

    W9_1 = tf.Variable(tf.truncated_normal([3,3,3,512+512,512], stddev=0.02))
    b9_1 = tf.Variable(tf.constant(0.0, shape=[512]))
    relu9_1 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(block1, W9_1, strides=[1, 1, 1, 1, 1], padding="SAME"), b9_1))
    W9_2 = tf.Variable(tf.truncated_normal([3,3,3,512,512], stddev=0.02))
    b9_2 = tf.Variable(tf.constant(0.0, shape=[512]))
    relu9_2 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(relu9_1, W9_2, strides=[1, 1, 1, 1, 1], padding="SAME"), b9_2))

    #relu9_2 = attention(relu9_2)

    W_trans2 = tf.Variable(tf.truncated_normal([4,4,4,256,512], stddev=0.02))
    b_trans2 = tf.Variable(tf.constant(0.0, shape=[256]))
    conv_trans2 = tf.nn.bias_add(tf.nn.conv3d_transpose(relu9_2, W_trans2, output_shape = tf.shape(relu3_2), strides=[1, 1, 2, 2, 1], padding="SAME"), b_trans2)
    print(conv_trans2.shape)

    block2 = tf.concat([relu3_2,conv_trans2], -1)

    W10_1 = tf.Variable(tf.truncated_normal([3,3,3,256+256,256], stddev=0.02))
    b10_1 = tf.Variable(tf.constant(0.0, shape=[256]))
    relu10_1 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(block2, W10_1, strides=[1, 1, 1, 1, 1], padding="SAME"), b10_1))
    W10_2 = tf.Variable(tf.truncated_normal([3,3,3,256,256], stddev=0.02))
    b10_2 = tf.Variable(tf.constant(0.0, shape=[256]))
    relu10_2 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(relu10_1, W10_2, strides=[1, 1, 1, 1, 1], padding="SAME"), b10_2))

    #relu10_2 = attention(relu10_2)

    W_trans3 = tf.Variable(tf.truncated_normal([4,4,4,128,256], stddev=0.02))
    b_trans3 = tf.Variable(tf.constant(0.0, shape=[128]))
    conv_trans3 = tf.nn.bias_add(tf.nn.conv3d_transpose(relu10_2, W_trans3, output_shape = tf.shape(relu2_2), strides=[1, 1, 2, 2, 1], padding="SAME"), b_trans3)
    print(conv_trans3.shape)

    block3 = tf.concat([relu2_2,conv_trans3], -1)

    W11_1 = tf.Variable(tf.truncated_normal([3,3,3,128+128,128], stddev=0.02))
    b11_1 = tf.Variable(tf.constant(0.0, shape=[128]))
    relu11_1 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(block3, W11_1, strides=[1, 1, 1, 1, 1], padding="SAME"), b11_1))
    W11_2 = tf.Variable(tf.truncated_normal([3,3,3,128,128], stddev=0.02))
    b11_2 = tf.Variable(tf.constant(0.0, shape=[128]))
    relu11_2 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(relu11_1, W11_2, strides=[1, 1, 1, 1, 1], padding="SAME"), b11_2))

    #relu11_2 = attention(relu11_2)

    W_trans4 = tf.Variable(tf.truncated_normal([4,4,4,64,128], stddev=0.02))
    b_trans4 = tf.Variable(tf.constant(0.0, shape=[64]))
    conv_trans4 = tf.nn.bias_add(tf.nn.conv3d_transpose(relu11_2, W_trans4, output_shape = tf.shape(relu1_2), strides=[1, 1, 2, 2, 1], padding="SAME"), b_trans4)
    print(conv_trans4.shape)

    block4 = tf.concat([relu1_2,conv_trans4], -1)

    W12_1 = tf.Variable(tf.truncated_normal([3,3,3,64+64,64], stddev=0.02))
    b12_1 = tf.Variable(tf.constant(0.0, shape=[64]))
    relu12_1 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(block4, W12_1, strides=[1, 1, 1, 1, 1], padding="SAME"), b12_1))
    W12_2 = tf.Variable(tf.truncated_normal([3,3,3,64,64], stddev=0.02))
    b12_2 = tf.Variable(tf.constant(0.0, shape=[64]))
    relu12_2 = tf.nn.relu(tf.nn.bias_add(tf.nn.conv3d(relu12_1, W12_2, strides=[1, 1, 1, 1, 1], padding="SAME"), b12_2))

    #relu12_2 = attention(relu12_2)

    #relu12_2 = multi_resolution_conv(relu12_2)

    '''
    W15_1 = tf.Variable(tf.truncated_normal([3,3,3,64+64,64], stddev=0.02))
    b15_1 = tf.Variable(tf.constant(0.0, shape=[64]))
    relu15_1 = tf.nn.bias_add(tf.nn.conv3d(relu12_2, W15_1, strides=[1, 1, 1, 1, 1], padding="SAME"), b15_1)
    W15_2 = tf.Variable(tf.truncated_normal([3,3,3,64,64], stddev=0.02))
    b15_2 = tf.Variable(tf.constant(0.0, shape=[64]))
    relu15_2 = tf.nn.bias_add(tf.nn.conv3d(relu15_1, W15_2, strides=[1, 1, 1, 1, 1], padding="SAME"), b15_2)
    '''

    W16_1 = tf.Variable(tf.truncated_normal([1,1,1,64,CLASS_NUM], stddev=0.02))
    b16_1 = tf.Variable(tf.constant(0.0, shape=[CLASS_NUM]))
    relu16_1 = tf.nn.bias_add(tf.nn.conv3d(relu12_2, W16_1, strides=[1, 1, 1, 1, 1], padding="SAME"), b16_1)

    #relu16_1 = attention(relu16_1)
     
    #logits = tf.reduce_sum(relu16_1,1)
    logits = relu16_1
    print(logits.shape)
    
    annotation_pred = tf.argmax(logits, axis=-1)
    
    return annotation_pred, logits#tf.nn.softmax(logits)
