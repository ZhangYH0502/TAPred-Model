# TAPred-Model
This is a time adaptive prediction model for the location of future GA growth in SD-OCT images.
The input of the prediction model is the first two follow-up visits and the output is the predicted GA location of the third follow-up visits.

The network architecture is shown as follows:
![blockchain](https://github.com/ZhangYH0502/TAPred-Model/blob/master/figure/Figure%202.jpg "network architecture")

Model Description:
  The code mainly includes the data preparation and model running. The data preraration contains the image flattening and data serialization, which is writen with MATLAB. The main prediction model is writen with Tensorflow 3.5. 
 
How to test the new GA follow-up visits:

(1) download the testing GA data and trained model from "https://data.mendeley.com/datasets/vcv2893vyz/draft?a=d8823d81-0884-4993-a53b-55cc9fbd66cd". You can also use your own data and then use our provided pre-processing methods to pre-process your data;

(2) run the "test\matlab\Extract_TestingSamples_for_rnn.m" to generate the model input;

(3) run the "test\Bi-LSTM_with_time\test.py" to generate the prediction results;

(4) run the "test\matlab\combine_RNN_results.m" and "test\matlab\Extract_TestingSamples_for_3DUNET.m" to generate the 3D-UNet input;

(5) run the "test\UNet_3D\main.py" to generate the refinement results;

(6) run the "test\matlab\Combine_3DUNET_results.m" to visualize final GA prediction.

How to train your model for GA location:

(1) The GA data from the work can be available by submit a request for Standford University;

(2) To run the code, several pre-processing steps need to be prepared in advance.
    (a) IS/OS layer segmentation, which can be segmented by an automated or manual layer segmentation method;
        running "TAPred-Model/data_prepare/preprocess/Layer_Segmentation/Bscan_GAseg"
    (b) GA registration: which can be performed with the automated registration method or manual registration;
        running "TAPred-Model/data_prepare/preprocess/GA_Registration/demos/SIFTflowDemo"
    (c) GA segmentation: the segmented GA masks can be used train the model as supervision labels, which can be obtained                         by automated GA segmentation method or manual annotation.
        running "TAPred-Model/data_prepare/preprocess/GA_Segmentation/Bscan_GAseg"

(3) Run "data_prepare/preprocess/flatten_img.m" to flatten the images.

(4) Run "data_prepare/data_extraction_for_BiLSTM" to seralize the data to obtain the training & testing samples.

(5) Run "train/BiLSTM/train_LSTM.py" to train the first half part of prediction.

(6) Run the "data_prepare/data_extraction_for_UNet3D/Extract_OpticFlow_for_3DUNET.m" to obtain simulated GA growth maps.

(7) Run the "data_prepare/data_extraction_for_UNet3D/Extract_TrainingSamples_for_3DUNET.m" to combine the output of BiLSTM and    
    simulated GA growth maps to obtain the training data for 3D U-Net.

(8) Run "train/UNet3D/main.py" to train the second half part of prediction.

(9) Test your model.

The visualization of predicted results are shown as follows, the red lines denote the GA location of the previous follow-up visit, the blue line denote the real current GA location and green line denote the predicted GA location:
![blockchain](https://github.com/ZhangYH0502/TAPred-Model/blob/master/figure/Figure%208.jpg "network architecture")
