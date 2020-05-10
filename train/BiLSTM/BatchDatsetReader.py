import numpy as np
import scipy.io
import os
import random
import h5py
import math

class BatchDatset:

    def __init__(self, path):
        print("Initializing Batch Dataset Reader...")
        self.path_list = [];
        self.batch_offset = 0
        self.epochs_completed = 0
        self.path = path
        self._all_path()

    def next_batch(self, batch_size):
        start = self.batch_offset
        self.batch_offset += batch_size
        if self.batch_offset > len(self.path_list):
            self.epochs_completed += 1
            print("****************** Epochs completed: " + str(self.epochs_completed) + "******************")
            random.shuffle(self.path_list)
            start = 0
            self.batch_offset = batch_size
        end = self.batch_offset
        path_temp = self.path_list[start:end]
        
        images = np.arange(batch_size*578*224).reshape(batch_size,578,224)
        annotations = np.arange(batch_size*2*1).reshape(batch_size,2,1)
        time_interval = np.arange(batch_size*2).reshape(batch_size,2)
        
        k = -1
        for subpath in path_temp:
            #data = scipy.io.loadmat(subpath)
            #print(subpath)
            data = h5py.File(subpath)
            k = k+1;
            images[k,:,:]=np.transpose(np.array(data['sample']),(1,0))
            annotations[k,:,:]=np.array(data['label'])        
            #print(annotations[k,:,:])
            
            t1 = np.array(data['time_interval1'])
            t2 = np.array(data['time_interval2'])
            #print(t1)
            t3 = t1+t2
            #print(t3)
            t3 = math.exp(t3/(t3+t2))
            t2 = math.exp(t2/(t3+t2))
            
            time_interval[k,0] = t3
            time_interval[k,1] = t2
        #print(annotations)
            
        return images, annotations, time_interval


    def _all_path(self):
        for maindir, subdir, file_name_list in os.walk(self.path):
            for filename in file_name_list:
                apath = os.path.join(maindir, filename)
                self.path_list.append(apath)
