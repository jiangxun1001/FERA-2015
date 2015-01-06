function [data_train, labels_train, data_devel, labels_devel, raw_devel, PC, means_norm, stds_norm] = ...
    Prepare_HOG_AU_data_generic_intensity(train_users, devel_users, au_train, rest_aus, bp4d_dir, hog_data_dir, pca_file)

%%
addpath(genpath('../data extraction/'));

% First extracting the labels
[ labels_train, valid_ids_train, vid_ids_train ] = extract_BP4D_labels_intensity(bp4d_dir, train_users, au_train);

% Reading in the HOG data (of only relevant frames)
[train_appearance_data, valid_ids_train_hog, vid_ids_train_string] = Read_HOG_files(train_users, [hog_data_dir, '/train/']);

% Subsample the data to make training quicker
labels_train = cat(1, labels_train{:});
valid_ids_train = logical(cat(1, valid_ids_train{:}));

% Remove two thirds of negative examples (to balance the training data a bit)
inds_train = 1:size(labels_train,1);
neg_samples = inds_train(labels_train == 0);
reduced_inds = true(size(labels_train,1),1);
reduced_inds(neg_samples(round(1:1.5:end))) = false;

% also remove invalid ids based on CLM failing or AU not being labelled
reduced_inds(~valid_ids_train) = false;
reduced_inds(~valid_ids_train_hog) = false;

labels_train = labels_train(reduced_inds,:);
train_appearance_data = train_appearance_data(reduced_inds,:);
vid_ids_train_string = vid_ids_train_string(reduced_inds,:);

%% Extract devel data

% First extracting the labels
[ labels_devel, valid_ids_devel, vid_ids_devel ] = extract_BP4D_labels_intensity(bp4d_dir, devel_users, au_train);

% Reading in the HOG data (of only relevant frames)
[devel_appearance_data, valid_ids_devel_hog, vid_ids_devel_string] = Read_HOG_files(devel_users, [hog_data_dir, '/devel/']);

labels_devel = cat(1, labels_devel{:});

% normalise the data
load(pca_file);
     
% Grab all data for validation as want good params for all the data
raw_devel = devel_appearance_data;

devel_appearance_data = bsxfun(@times, bsxfun(@plus, devel_appearance_data, -means_norm), 1./stds_norm);
train_appearance_data = bsxfun(@times, bsxfun(@plus, train_appearance_data, -means_norm), 1./stds_norm);

data_train = train_appearance_data * PC;
data_devel = devel_appearance_data * PC;

end