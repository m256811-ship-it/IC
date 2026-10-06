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
├── generateVLCChannelH_ChannelModelingSlides.m
├── discretizeReflectiveWalls_ChannelModelingSlides.m
├── addSingleNLOSPath_ChannelModelingSlides.m
├── addPathLinear_ChannelModelingSlides.m
├── trimImpulse_ChannelModelingSlides.m
├── physicalToSymbol_ChannelModelingSlides.m
├── rotationMatrixRPY.m
├── orientationVectorRPY.m
├── ookMod.m
├── addAwgnFromEbNo.m
├── makeVLCWindows.m
├── generateReceiverDataset.m
├── buildNeuralReceiver.m
├── trainNeuralReceiver.m
├── evaluateReceivers.m
├── plotVLCChannel.m
├── plotBERResults.m
├── plotReceiverDiagnostics.m
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
3. gera a resposta impulsiva do canal;
4. gera dados de treinamento e validação;
5. treina o receptor neural;
6. avalia os três receptores;
7. gera os gráficos.

## Script principal

O arquivo `autoencoderVLC4paredes.m` funciona como orquestrador da simulação. A lógica interna foi separada em funções para facilitar manutenção, comparação entre cenários e testes automatizados.

Fluxo:

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

## Configuração do canal

Os parâmetros físicos, geométricos e de discretização ficam em:

```text
getChannelParams.m
```

### Principais parâmetros

| Parâmetro | Significado |
|---|---|
| `channelParams.theta_deg` | Semiângulo usado no modelo Lambertiano |
| `channelParams.P_total_mW` | Potência óptica total |
| `channelParams.FOV_deg` | Campo de visão do receptor |
| `channelParams.Adet` | Área ativa do fotodetector |
| `channelParams.indexLens` | Índice de refração do concentrador |
| `channelParams.Tsc` | Ganho/transmitância do filtro óptico |
| `channelParams.room` | Dimensões da sala `[lx ly lz]` em metros |
| `channelParams.rho` | Coeficiente de reflexão das paredes |
| `channelParams.C` | Velocidade da luz em m/ns |
| `channelParams.delta_t_ns` | Resolução temporal da resposta impulsiva |
| `channelParams.tMax_ns` | Atraso máximo representado |
| `channelParams.Tsym_ns` | Intervalo usado atualmente na discretização por símbolo |
| `channelParams.patchesPerMeter` | Resolução espacial das paredes refletoras |
| `channelParams.includeLOS` | Ativa/desativa a componente LoS |
| `channelParams.includeNLOS` | Ativa/desativa as reflexões NLoS |
| `channelParams.normalize` | Normalização: `"sum"`, `"energy"` ou `"none"` |

### Posição de TX e RX

| Parâmetro | Significado |
|---|---|
| `channelParams.TP` | Posição do transmissor `[x y z]` |
| `channelParams.RP` | Posição do receptor `[x y z]` |

### Orientação

Vetores de referência:

```matlab
channelParams.n0Tx = [0 0 -1];
channelParams.n0Rx = [0 0  1];
```

Parâmetros de orientação:

```matlab
channelParams.txRoll_deg
channelParams.txPitch_deg
channelParams.txYaw_deg

channelParams.rxRoll_deg
channelParams.rxPitch_deg
channelParams.rxYaw_deg
```

A convenção de rotação utilizada é:

```text
R = Rz(yaw) * Ry(pitch) * Rx(roll)
```

### Grade de posições

| Parâmetro | Significado |
|---|---|
| `channelParams.txGridNx` | Número de posições TX em x |
| `channelParams.txGridNy` | Número de posições TX em y |
| `channelParams.rxGridNx` | Número de posições RX em x |
| `channelParams.rxGridNy` | Número de posições RX em y |
| `channelParams.txGridMargin` | Margem de TX em relação às bordas |
| `channelParams.rxGridMargin` | Margem de RX em relação às bordas |

A geração automática dos pares TX-RX ainda será implementada.

## Configuração do receptor

Os parâmetros de modulação, treinamento e avaliação ficam em:

```text
getDecoderParams.m
```

| Parâmetro | Significado |
|---|---|
| `decoderParams.Ntrain` | Número de bits de treinamento |
| `decoderParams.Nval` | Número de bits de validação |
| `decoderParams.Ntest` | Número de bits de teste |
| `decoderParams.A` | Amplitude OOK do bit 1 |
| `decoderParams.trainEbNo_dB` | Eb/N0 usado no treinamento |
| `decoderParams.EbNoVec_dB` | Valores de Eb/N0 usados na curva BER |
| `decoderParams.randomSeed` | Seed para reprodutibilidade |
| `decoderParams.hiddenLayer1Size` | Tamanho da primeira camada oculta |
| `decoderParams.hiddenLayer2Size` | Tamanho da segunda camada oculta |
| `decoderParams.numClasses` | Número de classes |
| `decoderParams.solverName` | Otimizador |
| `decoderParams.numEpochs` | Número de épocas |
| `decoderParams.miniBatchSize` | Tamanho do mini-batch |
| `decoderParams.initialLearnRate` | Learning rate inicial |
| `decoderParams.validationFrequency` | Frequência de validação |
| `decoderParams.detailedEbNoVec_dB` | Eb/N0 com dados detalhados salvos |
| `decoderParams.plotEbNo_dB` | Eb/N0 usado nos diagnósticos |
| `decoderParams.numViz` | Número máximo de observações para PCA/t-SNE |
| `decoderParams.Nshow` | Número de bits mostrado na comparação visual |

## Funções principais

### Canal

**`generateVLCChannelH_ChannelModelingSlides.m`**  
Gera a resposta impulsiva discreta do canal a partir dos parâmetros físicos, posições e orientações.

**`discretizeReflectiveWalls_ChannelModelingSlides.m`**  
Divide as quatro paredes laterais em patches e retorna centros, normais e áreas.

**`addSingleNLOSPath_ChannelModelingSlides.m`**  
Calcula a contribuição de primeira ordem de um patch refletor.

**`addPathLinear_ChannelModelingSlides.m`**  
Adiciona a contribuição de um caminho ao vetor temporal da resposta impulsiva.

**`rotationMatrixRPY.m`**  
Constrói a matriz de rotação roll-pitch-yaw.

**`orientationVectorRPY.m`**  
Aplica a rotação ao vetor normal de referência de TX ou RX.

**`trimImpulse_ChannelModelingSlides.m`**  
Remove regiões desnecessárias da resposta impulsiva.

**`physicalToSymbol_ChannelModelingSlides.m`**  
Converte a resposta física para a representação discreta usada pelo sistema.

### Transmissão e dados

**`ookMod.m`**  
Mapeia bits em símbolos OOK:

```text
0 -> 0
1 -> A
```

**`addAwgnFromEbNo.m`**  
Adiciona AWGN ao sinal.

**`makeVLCWindows.m`**  
Transforma o sinal recebido em janelas para o receptor neural.

**`generateReceiverDataset.m`**  
Centraliza:

```text
bits -> OOK -> canal FIR -> AWGN -> janelas
```

### Receptor neural

**`buildNeuralReceiver.m`**  
Constrói a arquitetura da rede neural.

**`trainNeuralReceiver.m`**  
Configura as opções de treinamento e treina a rede.

Saídas:

- `rxNet`: rede treinada;
- `trainInfo`: informações do treinamento.

### Avaliação

**`evaluateReceivers.m`**  
Avalia o receptor neural, o detector por limiar e o equalizador ZF.

Principais saídas:

```matlab
results.EbNoVec_dB
results.BER_Neural
results.BER_Threshold
results.BER_ZF
results.detailedTests
```

### Visualização

**`plotVLCChannel.m`**  
Plota a resposta impulsiva discreta.

**`plotBERResults.m`**  
Plota as curvas BER dos três receptores.

**`plotReceiverDiagnostics.m`**  
Gera matriz de confusão, visualização PCA/t-SNE e comparação de bits.

## Modelo de canal

### LoS

O caminho direto utiliza:

- `phi`: ângulo de emissão do TX;
- `psi`: ângulo de incidência no RX.

O caminho LoS é aceito quando a geometria é válida e:

```text
psi <= FOV
```

### NLoS

As quatro paredes laterais são discretizadas em patches.

Para cada patch são calculados:

- emissão TX -> patch;
- incidência na parede;
- saída da parede;
- incidência no RX;
- distâncias dos dois trechos;
- atraso;
- ganho do caminho.

Piso e teto não são superfícies refletoras no modelo atual.

## Testes automatizados

Os testes de canal estão em:

```text
autoencoderVLC4paredesTest.m
```

Execute com:

```matlab
runtests( ...
    "autoencoderVLC4paredesTest", ...
    "UseTestBrowser", true);
```

Os testes atuais verificam:

- independência do LoS em relação à discretização das paredes;
- convergência espacial do NLoS;
- convergência do canal completo;
- geometria fora do eixo;
- efeito da orientação RPY;
- bloqueio por FOV.

### Convergência espacial

Foram avaliadas resoluções de:

```text
2, 5, 10, 20 e 40 patches/m
```

As diferenças entre resoluções sucessivas diminuem com o refinamento, indicando convergência da discretização espacial.

## Exemplos de configuração

### Receptor deslocado e inclinado

```matlab
channelParams = getChannelParams();

channelParams.RP = [0.5 0.4 -1.5];
channelParams.rxPitch_deg = 15;
```

### Apenas LoS

```matlab
channelParams.includeLOS = true;
channelParams.includeNLOS = false;
```

### Apenas NLoS

```matlab
channelParams.includeLOS = false;
channelParams.includeNLOS = true;
```

### Maior resolução espacial

```matlab
channelParams.patchesPerMeter = 10;
```

### Outros valores de Eb/N0

```matlab
decoderParams = getDecoderParams();
decoderParams.EbNoVec_dB = 0:5:30;
```

## Observações

- `Lwin` é atualmente definido como `length(h)`.
- `Tsym_ns` ainda será separado de forma mais rigorosa da discretização temporal do canal.
- O modelo de potência e a definição de Eb/N0 ainda serão refinados.
- A geração automática de grades e pares TX-RX ainda será implementada.
- Testes automatizados do decoder e do sistema completo serão adicionados posteriormente.

## Próximos passos

- gerar grades de posições TX e RX;
- criar pares TX-RX automaticamente;
- avaliar múltiplas posições e orientações;
- separar `delta_t_ns` e `Tsym_ns`;
- revisar potência, responsividade do fotodiodo e Eb/N0;
- criar testes automatizados do decoder e do sistema fim a fim.
