# Plano de Evolução do Modelo de Canal VLC

Este documento descreve as próximas etapas de desenvolvimento do modelo de canal VLC utilizado no projeto. O objetivo é evoluir gradualmente de um cenário simplificado, com transmissor e receptor fixos e alinhados, para uma representação mais geral do canal óptico, capaz de incorporar variações espaciais, orientações, multipercurso, ganho físico e diferentes condições de ruído.

A evolução será realizada de forma incremental para permitir a identificação separada dos efeitos de **atenuação**, **multipercurso/ISI** e **variabilidade espacial** sobre o desempenho dos receptores.

---

## 1. Generalização espacial e geométrica do canal

### Objetivo

Permitir a geração do canal para diferentes posições e orientações de transmissor e receptor dentro da sala, eliminando hipóteses geométricas excessivamente restritivas.

### 1.1 Posições e orientações de TX e RX

Atualmente, o modelo assume transmissor e receptor paralelos e alinhados, o que permite simplificar o termo angular do ganho LoS para uma expressão proporcional a


$cos^{m+1}(\phi)$.

Essa hipótese deverá ser removida.

As próximas modificações incluem:

- discretizar as superfícies relevantes da sala, inicialmente o teto e o plano de recepção;
- criar uma malha de posições possíveis para transmissor e receptor;
- permitir diferentes combinações de posições de TX e RX;
- introduzir explicitamente os vetores normais de orientação de TX e RX;
- calcular separadamente o ângulo de irradiação do LED,$\phi$, e o ângulo de incidência no fotodetector,$\psi$;
- deixar de assumir, de forma geral, que $\phi = \psi$.

O cálculo LoS deverá, portanto, ser baseado diretamente na geometria entre posição, direção de propagação e vetores normais dos dispositivos.

A formulação NLoS também deverá ser revisada para que os ângulos envolvidos nos trajetos TX–parede e parede–RX sejam calculados geometricamente a partir das normais das superfícies refletoras.

---

### 1.2 Discretização das superfícies refletoras

A representação atual das paredes deverá ser reformulada para diferenciar corretamente pontos de uma malha de **elementos de área**.

Em vez de interpretar diretamente os pontos obtidos com `linspace` como elementos refletivos, cada superfície deverá ser dividida em **células ou patches**, utilizando o centro geométrico de cada elemento para o cálculo da reflexão.

Para uma parede perpendicular ao eixo \(x\), por exemplo, cada patch terá área $Delta A = \Delta y \, \Delta z$.

Analogamente:

- paredes perpendiculares a $\(y\)$: $\Delta A = \Delta x \, \Delta z$;

- superfícies perpendiculares a \(z\): $\Delta A = \Delta x \, \Delta y$.

Também deverão ser revisadas as definições de $\(N_x\)$, $\(N_y\)$ e $\(N_z\)$, garantindo consistência entre número de divisões, dimensões físicas e área dos patches.

Após essa implementação, deverá ser realizado um **teste de convergência espacial**, aumentando progressivamente a resolução da malha até que a resposta impulsiva varie pouco com novos refinamentos.

> Esta etapa busca aumentar a precisão espacial do modelo LoS/NLoS. Não há introdução de não linearidade no canal.

---

## 2. Discretização temporal do canal

### Objetivo

Estabelecer corretamente a relação entre a resposta impulsiva física $\(h(t)\)$, a duração dos símbolos e o canal discreto utilizado na transmissão digital.

### 2.1 Separação entre $\Delta t$ e $T_{\text{sym}}$

Dois parâmetros devem ser tratados separadamente:

- `delta_t_ns`: resolução temporal utilizada para representar a resposta impulsiva física \(h(t)\);
- `Tsym_ns`: duração física de um símbolo transmitido.

A relação

$T_{\text{sym}} = \Delta t$

não deve ser imposta automaticamente.

O valor de $T_{\text{sym}}$ deverá ser definido a partir da taxa de símbolos considerada no sistema,

$R_s = \frac{1}{T_{\text{sym}}}$

e comparado com o espalhamento temporal do canal.

No modelo atual,

```matlab
delta_t_ns = 0.5;
Tsym_ns    = 0.5;
```

o que corresponde implicitamente a uma taxa de aproximadamente

$R_s = 2\ \text{Gbaud}$.

Essa taxa deverá ser explicitamente justificada ou substituída por um valor compatível com o cenário de comunicação estudado.

---

### 2.2 Conversão de $h_{\text{phys}}$ para $(h_{\text{sym}}$

Após a definição adequada de $T_{\text{sym}}$, será necessário revisar a função `physicalToSymbol`.

Atualmente, a função soma as contribuições da resposta impulsiva física contidas dentro de cada intervalo de símbolo.

Essa operação deverá ser interpretada fisicamente e relacionada ao modelo de transmissão e recepção adotado.

Em um modelo mais geral, o canal discreto equivalente poderá ser obtido a partir da resposta contínua resultante de

$p_{\text{TX}}(t) * h(t) * p_{\text{RX}}(t)$,

onde:

- $p_{\text{TX}}(t)$ representa a forma de pulso transmitida;
- $h(t)$ representa o canal óptico;
- $p_{\text{RX}}(t)$ representa a resposta do filtro ou integração no receptor.

A partir dessa resposta equivalente, deverá ser realizada a amostragem na taxa de símbolos para obter $h[k]$.

---

### 2.3 Aplicação do canal ao sinal transmitido

Uma vez definido corretamente o canal discreto equivalente, deverá ser verificada a validade da operação

$y[k] = \sum_l h[l]x[k-l]$.

No código MATLAB, essa operação é atualmente realizada por

```matlab
y = filter(h, 1, x);
```

Essa implementação é válida desde que:

- `x[k]` esteja definido na taxa de símbolos;
- `h[k]` represente o canal equivalente na mesma escala temporal.

Como `x[k]` representa atualmente símbolos OOK, o vetor utilizado em `filter` também deve representar a resposta do canal discretizada na taxa de símbolos.

---

## 3. Ganho do canal, potência e ruído

### Objetivo

Definir quais características físicas do canal serão preservadas ao comparar diferentes posições e orientações de TX/RX.

---

### 3.1 Normalização da resposta impulsiva

Atualmente é utilizada a normalização

$\tilde h[k] =
\frac{h[k]}
{\sum_k h[k]}$.

Essa operação preserva aproximadamente o formato relativo da resposta impulsiva e, consequentemente, as características de multipercurso e ISI.

Entretanto, ela remove o ganho total do canal.

Serão considerados dois cenários experimentais.

#### Canal normalizado

Usado para estudar principalmente:

- multipercurso;
- espalhamento temporal;
- ISI;
- capacidade de equalização dos receptores.

Nesse caso, diferenças de path loss entre posições são removidas.

#### Canal físico não normalizado

Usado para preservar também:

- atenuação;
- ganho DC do canal;
- diferenças de potência recebida entre posições;
- impacto da geometria sobre a SNR recebida.

Os dois casos poderão ser mantidos como experimentos independentes.

---

### 3.2 Potência óptica transmitida

O parâmetro

```matlab
P_total_mW
```

já está presente no modelo, mas atualmente não participa diretamente da cadeia de transmissão.

Deverá ser feita uma separação clara entre o ganho do canal,h(t),e a potência óptica recebida, $P_r(t) = P_t(t) * h(t)$.

Será necessário definir:

- qual potência representa o estado `ON` da modulação OOK;
- se o sinal transmitido será representado diretamente em potência óptica;
- se o estado `OFF` será considerado igual a zero ou incluirá alguma potência de bias;
- como a potência óptica recebida será utilizada no receptor.

Em uma etapa posterior, poderá ser incluída a responsividade do fotodiodo $R$, permitindo converter potência óptica recebida em corrente elétrica:

$i(t) = R\,P_r(t)$.

Essa escolha será particularmente importante quando forem comparadas posições diferentes de TX e RX.

---

### 3.3 Definição de $E_b/N_0$ e AWGN

Atualmente, a energia utilizada para definir o nível de ruído é calculada antes da aplicação do canal:

$E_b = \mathrm{mean}(x_{\text{Tx}}^2)$.

Essa definição deverá ser revisada de acordo com o objetivo de cada experimento.

Serão considerados dois casos principais.

#### Potência transmitida e ruído constantes

Mantêm-se constantes:

- potência de transmissão;
- nível de ruído do receptor.

Nesse caso, a SNR recebida dependerá do ganho do canal e variará com a posição do receptor.

Esse cenário representa de forma mais direta a influência da geometria e da atenuação.

#### $E_b/N_0$ recebido fixo

O ruído é ajustado separadamente para cada canal para manter aproximadamente o mesmo $E_b/N_0$ após a propagação.

Esse cenário permite reduzir o efeito da atenuação e estudar principalmente:

- multipercurso;
- ISI;
- dificuldade de equalização.

A escolha deverá ser explicitada nos gráficos de BER e na metodologia experimental.

---

## 4. Hipóteses e validação experimental

### 4.1 Atrasos relativos e sincronização

Inicialmente será mantida a função `trimImpulse`, responsável por eliminar os zeros anteriores à primeira chegada significativa do canal.

Isso transforma a resposta impulsiva em uma representação baseada em **atrasos relativos**, removendo o tempo absoluto de propagação.

Essa escolha equivale a assumir **sincronização temporal ideal** entre transmissor e receptor.

A hipótese deverá ser documentada explicitamente.

O atraso absoluto poderá ser preservado futuramente caso o projeto passe a investigar:

- sincronização;
- mobilidade;
- Time of Arrival;
- posicionamento;
- estimação de distância.

---

### 4.2 Sequência incremental de experimentos

Após a estabilização do modelo físico, os experimentos deverão ser realizados de maneira incremental.

---

## 5. Questão central de investigação

O objetivo final será determinar em quais condições o receptor baseado em rede neural apresenta vantagem em relação às técnicas convencionais.

Em particular, os experimentos deverão permitir responder se o eventual ganho do receptor neural decorre de:

1. melhor capacidade de lidar com ISI e multipercurso;
2. capacidade de adaptação a diferentes condições espaciais do canal;
3. maior robustez a variações de ganho e SNR;
4. ou simplesmente de uma comparação com uma baseline convencional que não está tratando adequadamente o canal.

A comparação deverá, portanto, utilizar baselines clássicas coerentes com cada cenário, de forma que qualquer ganho atribuído ao aprendizado neural possa ser analisado de maneira justa.

---
