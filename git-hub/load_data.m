function [data_set, n_vis]=load_data(m,m_test)

%LOAD TRAINING AND TEST DATA
temp.inputs = loadMNISTImages('train-images.idx3-ubyte');
temp.targets=transpose(loadMNISTLabels('train-labels.idx1-ubyte'));
data_set.train=extract_subset(temp, 1, m);

clear temp;

temp.inputs = loadMNISTImages('t10k-images.idx3-ubyte');
temp.targets=transpose(loadMNISTLabels('t10k-labels.idx1-ubyte'));

data_set.test=extract_subset(temp, 1, m_test);
clear temp;
[n_vis,m]=size(data_set.train.inputs);


%ONE-HOT ENCODING OF THE TARGETS
temp=zeros(10,m);
for i=1:m
    temp(data_set.train.targets(i)+1,i)=1;
end
data_set.train.targets=temp;
clear temp;


temp=zeros(10,m_test);
for i=1:m_test
    temp(data_set.test.targets(i)+1,i)=1;
end
data_set.test.targets=temp;
clear temp;

    function images = loadMNISTImages(filename)
        
        fp = fopen(filename, 'rb');
        assert(fp ~= -1, ['Could not open ', filename, '']);
        
        magic = fread(fp, 1, 'int32', 0, 'ieee-be');
        assert(magic == 2051, ['Bad magic number in ', filename, '']);
        
        numImages = fread(fp, 1, 'int32', 0, 'ieee-be');
        numRows = fread(fp, 1, 'int32', 0, 'ieee-be');
        numCols = fread(fp, 1, 'int32', 0, 'ieee-be');
        
        images = fread(fp, inf, 'unsigned char');
        images = reshape(images, numCols, numRows, numImages);
        images = permute(images,[2 1 3]);
        
        fclose(fp);
        
        images = reshape(images, size(images, 1) * size(images, 2), size(images, 3));
        images = double(images) / 255;
        
    end

    function labels = loadMNISTLabels(filename)
        fp = fopen(filename, 'rb');
        assert(fp ~= -1, ['Could not open ', filename, '']);
        magic = fread(fp, 1, 'int32', 0, 'ieee-be');
        assert(magic == 2049, ['Bad magic number in ', filename, '']);
        numLabels = fread(fp, 1, 'int32', 0, 'ieee-be');
        labels = fread(fp, inf, 'unsigned char');
        assert(size(labels,1) == numLabels, 'Mismatch in label count');
        fclose(fp);
        
    end
end