function layersRx = buildNeuralReceiver(Lwin, decoderParams)
% BUILDNEURALRECEIVER
%
% Constroi a arquitetura do receptor neural OOK-VLC.

layersRx = [

featureInputLayer( ...
Lwin, ...
"Name", "received_window", ...
"Normalization", "zscore")

fullyConnectedLayer( ...
decoderParams.hiddenLayer1Size, ...
"Name", "fc1")

reluLayer("Name", "relu1")

fullyConnectedLayer( ...
decoderParams.hiddenLayer2Size, ...
"Name", "fc2")

reluLayer("Name", "relu2")

fullyConnectedLayer( ...
decoderParams.numClasses, ...
"Name", "fc_out")

softmaxLayer("Name", "softmax")

classificationLayer( ...
"Name", "class_output")

];

end