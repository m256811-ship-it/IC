# Autoencoder VLC

Simulação de um sistema de comunicação por luz visível (VLC) com modulação OOK, canal FIR baseado em geometria física e receptor neural.

O fluxo principal do sistema é:

```text
bits -> OOK -> canal VLC -> AWGN -> receptor -> BER
```

O projeto compara três abordagens de recepção:

- receptor neural;
- detector OOK por limiar;
- equalizador Zero-Forcing (ZF).

## Funcionalidades

O modelo atual inclui:

- componente LoS;
- reflexões NLoS de primeira ordem nas quatro paredes laterais;
- discretização espacial das paredes em patches;
- posições tridimensionais de TX e RX;
- orientação de TX e RX por roll, pitch e yaw;
- discretização temporal da resposta impulsiva;
- geração de dados OOK com AWGN;
- treinamento e validação de receptor neural;
- cálculo de BER para diferentes valores de Eb/N0;
- comparação com detectores clássicos;
- testes automatizados de geometria e convergência do canal.

## Estrutura do projeto

```text
.
├── autoencoderVLC4paredes.m
├── getChannelParams.m
├── getDecoderParams.m
│
├── generateVLCChannelH_ChannelModelingSlides.m
├── discretizeReflectiveWalls_ChannelModelingSlides.m
├── addSingleNLOSPath_ChannelModelingSlides.m
├── addPathLinear_ChannelModelingSlides.m
├── trimImpulse_ChannelModelingSlides.m
├── physicalToSymbol_ChannelModelingSlides.m
├── rotationMatrixRPY.m
├── orientationVectorRPY.m
│
├── ookMod.m
├── addAwgnFromEbNo.m
├── makeVLCWindows.m
├── generateReceiverDataset.m
│
├── buildNeuralReceiver.m
├── trainNeuralReceiver.m
├── evaluateReceivers.m
│
├── plotVLCChannel.m
├── plotBERResults.m
├── plotReceiverDiagnostics.m
│
└── autoencoderVLC4paredesTest.m
```

## Requisitos

- MATLAB
- Deep Learning Toolbox
- Statistics and Machine Learning Toolbox recomendada para `tsne` e `pca`

Todos os arquivos `.m` devem estar na mesma pasta ou em diretórios incluídos no MATLAB Path.

## Como executar

Abra e execute:

```matlab
autoencoderVLC4paredes
```

O script principal:

1. carrega os parâmetros do canal;
2. carrega os parâmetros do receptor;
3. gera a resposta impulsiva do canal VLC;
4. gera os conjuntos de treinamento e validação;
5. treina o receptor neural;
6. avalia o receptor neural, o detector por limiar e o ZF;
7. gera os gráficos.

## Script principal

O arquivo `autoencoderVLC4paredes.m` funciona como orquestrador da simulação.

A lógica interna foi separada em funções para facilitar manutenção, testes e comparação entre diferentes cenários.

Fluxo principal:

```text
getChannelParams
        +
getDecoderParams
        ↓
geração do canal VLC
        ↓
geração dos datasets
        ↓
treinamento do receptor neural
        ↓
avaliação dos receptores
        ↓
visualização
```

A estrutura central é aproximadamente:

```matlab
channelParams = getChannelParams();
decoderParams = getDecoderParams();

rng(decoderParams.randomSeed);

RP  = channelParams.RP;
TP1 = channelParams.TP;

[hVLC, tVLC_ns] = ...
    generateVLCChannelH_ChannelModelingSlides( ...
        channelParams, TP1, RP);

h = hVLC(:).';

Lh = length(h);
Lwin = Lh;

trainData = generateReceiverDataset( ...
    h, ...
    Lwin, ...
    decoderParams.Ntrain, ...
    decoderParams.trainEbNo_dB, ...
    decoderParams);

valData = generateReceiverDataset( ...
    h, ...
    Lwin, ...
    decoderParams.Nval, ...
    decoderParams.trainEbNo_dB, ...
    decoderParams);

[rxNet, trainInfo] = trainNeuralReceiver( ...
    trainData, ...
    valData, ...
    Lwin, ...
    decoderParams);

results = evaluateReceivers( ...
    rxNet, ...
    h, ...
    Lwin, ...
    decoderParams);

plotVLCChannel(tVLC_ns, h);

plotBERResults(results);

plotReceiverDiagnostics( ...
    results, ...
    decoderParams);
```

---

# Configuração do canal

Os parâmetros físicos, geométricos e de discretização do canal ficam centralizados em:

```text
getChannelParams.m
```

Isso permite alterar o cenário sem modificar as funções internas do modelo.

## Principais parâmetros do canal

| Parâmetro | Significado |
|---|---|
| `channelParams.theta_deg` | Semiângulo usado para determinar a ordem Lambertiana |
| `channelParams.P_total_mW` | Potência óptica total |
| `channelParams.FOV_deg` | Campo de visão do receptor |
| `channelParams.Adet` | Área ativa do fotodetector |
| `channelParams.indexLens` | Índice de refração do concentrador óptico |
| `channelParams.Tsc` | Ganho/transmitância do filtro óptico |
| `channelParams.room` | Dimensões da sala `[lx ly lz]` em metros |
| `channelParams.rho` | Coeficiente de reflexão das paredes |
| `channelParams.C` | Velocidade da luz em m/ns |
| `channelParams.delta_t_ns` | Resolução temporal da resposta impulsiva |
| `channelParams.tMax_ns` | Atraso máximo representado |
| `channelParams.Tsym_ns` | Intervalo atualmente usado na discretização por símbolo |
| `channelParams.patchesPerMeter` | Resolução espacial das paredes refletoras |
| `channelParams.includeLOS` | Ativa ou desativa a componente LoS |
| `channelParams.includeNLOS` | Ativa ou desativa as reflexões NLoS |
| `channelParams.normalize` | Normalização do canal: `"sum"`, `"energy"` ou `"none"` |

## Geometria da sala

A sala é definida por:

```matlab
channelParams.room = [lx ly lz];
```

Configuração atual:

```matlab
channelParams.room = [2 2 3];
```

O sistema de coordenadas utiliza o centro da sala como origem:

```text
x ∈ [-lx/2, +lx/2]
y ∈ [-ly/2, +ly/2]
z ∈ [-lz/2, +lz/2]
```

## Posição de TX e RX

| Parâmetro | Significado |
|---|---|
| `channelParams.TP` | Posição do transmissor `[x y z]` |
| `channelParams.RP` | Posição do receptor `[x y z]` |

Por padrão, TX e RX são posicionados no centro dos planos superior e inferior da sala.

Exemplo:

```matlab
channelParams.TP = [0 0 1.5];
channelParams.RP = [0 0 -1.5];
```

## Orientação de TX e RX

Os vetores normais de referência são:

```matlab
channelParams.n0Tx = [0 0 -1];
channelParams.n0Rx = [0 0  1];
```

As orientações são definidas por:

```matlab
channelParams.txRoll_deg
channelParams.txPitch_deg
channelParams.txYaw_deg

channelParams.rxRoll_deg
channelParams.rxPitch_deg
channelParams.rxYaw_deg
```

A matriz de rotação utilizada é:

```text
R = Rz(yaw) * Ry(pitch) * Rx(roll)
```

Exemplo de receptor inclinado:

```matlab
channelParams.rxPitch_deg = 15;
```

## Grade de posições TX/RX

Os seguintes parâmetros serão usados na geração automática das posições:

| Parâmetro | Significado |
|---|---|
| `channelParams.txGridNx` | Número de posições TX no eixo x |
| `channelParams.txGridNy` | Número de posições TX no eixo y |
| `channelParams.rxGridNx` | Número de posições RX no eixo x |
| `channelParams.rxGridNy` | Número de posições RX no eixo y |
| `channelParams.txGridMargin` | Distância mínima entre TX e as bordas |
| `channelParams.rxGridMargin` | Distância mínima entre RX e as bordas |

A geração automática dos pares TX-RX ainda será implementada.

---

# Modelo de canal

## LoS

O caminho direto utiliza dois ângulos independentes:

- `phi`: ângulo de emissão do transmissor;
- `psi`: ângulo de incidência no receptor.

O caminho LoS é considerado válido quando a geometria é fisicamente possível e:

```text
psi <= FOV
```

## NLoS

As quatro paredes laterais são consideradas superfícies refletoras.

Piso e teto não são superfícies refletoras no modelo atual.

As paredes são discretizadas em patches, e cada patch possui:

- posição do centro;
- vetor normal;
- área `dA`.

Para cada reflexão de primeira ordem são calculados:

- ângulo de emissão TX → patch;
- ângulo de incidência na parede;
- ângulo de saída da parede;
- ângulo de incidência no RX;
- distância TX → patch;
- distância patch → RX;
- atraso;
- ganho do caminho.

---

# Funções do modelo de canal

## `generateVLCChannelH_ChannelModelingSlides.m`

Função principal de geração do canal.

Recebe:

```matlab
channelParams
TP1
RP
```

e retorna:

```matlab
hVLC
tVLC_ns
```

onde:

- `hVLC` é a resposta impulsiva discreta;
- `tVLC_ns` é o vetor temporal correspondente.

## `discretizeReflectiveWalls_ChannelModelingSlides.m`

Discretiza as quatro paredes laterais em patches.

Retorna para cada parede:

- centros dos patches;
- normal da parede;
- área de cada patch.

## `addSingleNLOSPath_ChannelModelingSlides.m`

Calcula a contribuição NLoS de primeira ordem de um único patch refletor.

## `addPathLinear_ChannelModelingSlides.m`

Adiciona a contribuição de um caminho ao vetor discreto da resposta impulsiva.

## `rotationMatrixRPY.m`

Constrói a matriz de rotação a partir de:

```text
roll
pitch
yaw
```

## `orientationVectorRPY.m`

Aplica a matriz de rotação ao vetor normal de referência:

```text
n = R * n0
```

## `trimImpulse_ChannelModelingSlides.m`

Remove regiões desnecessárias da resposta impulsiva após a construção do canal.

## `physicalToSymbol_ChannelModelingSlides.m`

Realiza a conversão da resposta física para a representação discreta usada pelo sistema.

---

# Configuração do receptor

Os parâmetros do receptor, treinamento e avaliação ficam em:

```text
getDecoderParams.m
```

## Principais parâmetros

| Parâmetro | Significado |
|---|---|
| `decoderParams.Ntrain` | Número de bits de treinamento |
| `decoderParams.Nval` | Número de bits de validação |
| `decoderParams.Ntest` | Número de bits de teste |
| `decoderParams.A` | Amplitude OOK associada ao bit 1 |
| `decoderParams.trainEbNo_dB` | Eb/N0 usado durante o treinamento |
| `decoderParams.EbNoVec_dB` | Valores de Eb/N0 usados na avaliação |
| `decoderParams.randomSeed` | Seed usada para reprodutibilidade |
| `decoderParams.hiddenLayer1Size` | Número de neurônios da primeira camada oculta |
| `decoderParams.hiddenLayer2Size` | Número de neurônios da segunda camada oculta |
| `decoderParams.numClasses` | Número de classes de saída |
| `decoderParams.solverName` | Otimizador usado no treinamento |
| `decoderParams.numEpochs` | Número de épocas |
| `decoderParams.miniBatchSize` | Tamanho do mini-batch |
| `decoderParams.initialLearnRate` | Learning rate inicial |
| `decoderParams.validationFrequency` | Frequência de validação |
| `decoderParams.detailedEbNoVec_dB` | Eb/N0 para os quais são armazenados resultados detalhados |
| `decoderParams.plotEbNo_dB` | Eb/N0 usado nas figuras de diagnóstico |
| `decoderParams.numViz` | Número máximo de observações usadas no PCA/t-SNE |
| `decoderParams.Nshow` | Número de bits exibidos na comparação visual |

---

# Funções de transmissão e geração de dados

## `ookMod.m`

Implementa a modulação OOK:

```text
bit 0 -> 0
bit 1 -> A
```

## `addAwgnFromEbNo.m`

Adiciona ruído AWGN ao sinal de acordo com o Eb/N0 especificado.

## `makeVLCWindows.m`

Transforma o sinal recebido em janelas utilizadas como entrada do receptor neural.

Atualmente:

```matlab
Lwin = length(h);
```

## `generateReceiverDataset.m`

Centraliza a geração dos dados de treinamento, validação ou teste:

```text
bits
  ↓
OOK
  ↓
canal FIR
  ↓
AWGN
  ↓
janelas
```

A estrutura retornada contém:

```matlab
data.bits
data.x
data.yClean
data.y
data.X
data.Y
```

---

# Receptor neural

## `buildNeuralReceiver.m`

Constrói a arquitetura do receptor neural.

A arquitetura atual é:

```text
feature input
    ↓
fully connected
    ↓
ReLU
    ↓
fully connected
    ↓
ReLU
    ↓
fully connected
    ↓
softmax
    ↓
classification
```

## `trainNeuralReceiver.m`

Configura as opções de treinamento e treina a rede.

Exemplo:

```matlab
[rxNet, trainInfo] = trainNeuralReceiver( ...
    trainData, ...
    valData, ...
    Lwin, ...
    decoderParams);
```

Saídas:

- `rxNet`: rede neural treinada;
- `trainInfo`: informações do processo de treinamento.

---

# Avaliação dos receptores

## `evaluateReceivers.m`

Avalia três receptores:

1. receptor neural;
2. detector OOK por limiar;
3. equalizador Zero-Forcing.

Exemplo:

```matlab
results = evaluateReceivers( ...
    rxNet, ...
    h, ...
    Lwin, ...
    decoderParams);
```

Principais campos retornados:

```matlab
results.EbNoVec_dB
results.BER_Neural
results.BER_Threshold
results.BER_ZF
results.detailedTests
results.delay
results.thresholdSimple
```

## Detector por limiar

O detector utiliza o tap dominante do canal para alinhar o sinal recebido.

O limiar é definido por:

```matlab
thresholdSimple = ...
    0.5 * decoderParams.A * sum(h);
```

## Zero-Forcing

O equalizador utiliza:

```matlab
xZF = filter(1, h, y);
```

seguido por uma decisão por limiar:

```matlab
bitsHatZF = ...
    xZF > decoderParams.A/2;
```

---

# Visualização

## `plotVLCChannel.m`

Plota a resposta impulsiva discreta do canal.

## `plotBERResults.m`

Plota as curvas:

```text
BER Neural
BER Threshold
BER ZF
```

em função de Eb/N0.

## `plotReceiverDiagnostics.m`

Gera diagnósticos para o valor definido em:

```matlab
decoderParams.plotEbNo_dB
```

Inclui:

- matriz de confusão;
- visualização das janelas por t-SNE/PCA;
- comparação entre bits transmitidos e detectados.

---

# Testes automatizados

Os testes do modelo de canal estão em:

```text
autoencoderVLC4paredesTest.m
```

Para executar:

```matlab
runtests( ...
    "autoencoderVLC4paredesTest", ...
    "UseTestBrowser", ...
    true);
```

Os testes atuais verificam:

- independência do LoS em relação à resolução das paredes;
- convergência espacial do NLoS;
- convergência do canal completo;
- geometria fora do eixo;
- funcionamento da orientação RPY;
- bloqueio do caminho LoS pelo FOV.

## Validação da convergência espacial

Foram avaliadas resoluções de:

```text
2
5
10
20
40 patches/m
```

As diferenças entre resoluções sucessivas diminuem à medida que a malha é refinada.

Os resultados indicam convergência da discretização espacial.

---

# Exemplos de configuração

## Receptor deslocado

```matlab
channelParams = getChannelParams();

channelParams.RP = ...
    [0.5 0.4 -1.5];
```

## Receptor inclinado

```matlab
channelParams.rxPitch_deg = 15;
```

## Apenas LoS

```matlab
channelParams.includeLOS = true;
channelParams.includeNLOS = false;
```

## Apenas NLoS

```matlab
channelParams.includeLOS = false;
channelParams.includeNLOS = true;
```

## Alterar resolução das paredes

```matlab
channelParams.patchesPerMeter = 10;
```

## Alterar Eb/N0 de teste

```matlab
decoderParams = getDecoderParams();

decoderParams.EbNoVec_dB = 0:5:30;
```

## Alterar Eb/N0 de treinamento

```matlab
decoderParams.trainEbNo_dB = 20;
```

## Alterar arquitetura da rede

```matlab
decoderParams.hiddenLayer1Size = 64;
decoderParams.hiddenLayer2Size = 32;
```

---

# Observações

- `Lwin` é atualmente definido como `length(h)`.
- `Tsym_ns` ainda será separado de forma mais rigorosa de `delta_t_ns`.
- O modelo de potência e a definição de Eb/N0 ainda serão revisados.
- A responsividade física do fotodiodo ainda será incorporada.
- A geração automática das grades e pares TX-RX ainda será implementada.
- Testes automatizados do receptor neural e do sistema fim a fim ainda serão adicionados.

# Próximos passos

- gerar grades de posições TX e RX;
- criar pares TX-RX automaticamente;
- avaliar múltiplas posições e orientações;
- separar `delta_t_ns` e `Tsym_ns`;
- revisar potência e Eb/N0;
- incorporar responsividade do fotodiodo;
- criar testes automatizados do decoder;
- criar testes automatizados do sistema completo.
