function decoderParams = getDecoderParams()
% GETDECODERPARAMS
%
% Parametros do sistema OOK, treinamento do receptor neural
% e avaliacao de desempenho.

%% Dados

decoderParams.Ntrain = 200000;
decoderParams.Nval   = 50000;
decoderParams.Ntest  = 100000;

%% Modulacao

decoderParams.A = 1;

%% Eb/N0

decoderParams.trainEbNo_dB = 18;
decoderParams.EbNoVec_dB = 0:2:30;

%% Arquitetura da rede

decoderParams.hiddenLayer1Size = 32;
decoderParams.hiddenLayer2Size = 16;
decoderParams.numClasses = 2;

%% Treinamento

decoderParams.solverName = "adam";
decoderParams.numEpochs = 8;
decoderParams.miniBatchSize = 512;
decoderParams.initialLearnRate = 1e-3;
decoderParams.shuffle = "every-epoch";
decoderParams.validationFrequency = 100;

%% Saida durante treinamento

decoderParams.trainingPlot = "training-progress";
decoderParams.verbose = true;

%% Testes detalhados

decoderParams.detailedEbNoVec_dB = [10 20];

%% Reprodutibilidade

decoderParams.randomSeed = 10;

end