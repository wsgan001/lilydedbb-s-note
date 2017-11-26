# TensorFlow —— RNN Word2Vec

> `Word2Vec` 是一个可以将语言中字词转换为向量形式表达的模型

`One-Hot Encoder` 将字词转换为离散的单独的符号，但是这样对特征的编码是随机的，没有提供任何关联信息，没有考虑字词之间可能存在的关系

向量空间模型 (`Vector Space Models`)可以将字词转为连续值（相对于 `One-Hot Encoder` 的离散值）的向量表达，并且其中意思相近的词将被映射到向量空降中相近的位置

向量空间模型在NLP中主要依赖的假设是 `Distribution Hypothesis`，即**在相同语境中出现的词其语义也相近**

向量空间模型主要分为两类：

- `计数模型`：统计在语料库中，相邻出现的词的频率，在把这些计数统计结果转为小而稠密的矩阵，如 `Latent Semantic Analysis`
- `预测模型`：各具一个词周围临近的词推测出这个词，以及它的空间向量，如 `Neural Probability Language Models`

`Word2Vec` 是一种计算高效的预测模型，主要分为 `CBOW`（Continous Bag of Words）和 `Skip-Gram` 两种模型：

- `CBOW` 是从原始语句推测目标字词
- `Skip-Gram` 是从目标字词推测原始语句


使用 `Skip-Gram` 模式的 `Word2Vec` 示例（参考《TensorFlow 实战》实现）：

```python
import collections, math, os, random, zipfile
import urllib.request as request
import numpy as np
import tensorflow as tf

url = 'http://mattmahoney.net/dc/'
# 下载文本数据的函数
def maybe_download(filename, expected_bytes):
    if not os.path.exists(filename):
        # urllib.request.urlretrieve 下载数据的压缩文件并核对文件尺寸
        filename, _ = request.urlretrieve(url + filename, filename)
    # 核对文件尺寸
    stainfo = os.stat(filename)
    if stainfo.st_size == expected_bytes:
        print('Found and Vertified')
    else:
        print(stainfo.st_size)
        raise Exception('Failed to vertify ' + filename + '. Can you get to it with a browser?')
    return filename

# 下载文本数据
filename = maybe_download('text8.zip', 31344016)

def read_data(filename):
    with zipfile.ZipFile(filename) as f:
        # 使用 tf.compat.as_str 将数据转成单词的列表
        data = tf.compat.as_str(f.read(f.namelist()[0])).split()
    return data

words = read_data(filename)
print('Data Size ', len(words))

# 创建 vocabulary 词汇表
vocabulary_size = 50000
def build_dataset(words):
    count = [['UNK', -1]]
    # 使用 collections.Counter 统计单词的频数，并用 most_common 方法取 top 50000 频数的词作为 Vocabulary
    count.extend(collections.Counter(words).most_common(vocabulary_size - 1))
    # 将全部单词编号
    dictionary = dict()
    for word, _ in count:
        dictionary[word] = len(dictionary)
    data = list()
    unk_count = 0
    for word in words:
        if word in dictionary:
            index = dictionary[word]
        else:
            # top 50000 之外的词，认为 Unkown，编号为 0
            index = 0
            unk_count += 1
        data.append(index)

    count[0][1] = unk_count
    reverse_dictionary = dict(zip(dictionary.values(), dictionary.keys()))
    return data, count, dictionary, reverse_dictionary

data, count, dictionary, reverse_dictionary = build_dataset(words)

del words # 删除原始单词表，释放内存
print('Most common words (+UNK)', count[:5])
print('Sample data', data[:10], [reverse_dictionary[i] for i in data[:10]])
# Most common words (+UNK) [['UNK', 418391], ('the', 1061396), ('of', 593677), ('and', 416629), ('one', 411764)]
# Sample data [5237, 3082, 12, 6, 195, 2, 3137, 46, 59, 156] ['anarchism', 'originated', 'as', 'a', 'term', 'of', 'abuse', 'first', 'used', 'against']

data_index = 0
def generate_batch(batch_size, num_skips, skip_window):
    """
    生成训练用的 batch 数据，如 将原始数据 "the quick brown fox jumped over the lazy dog" 转为 (quick, the)、(quick, brown)、(brown, quick)、(brown, fox) 等样本
    :param batch_size: batch 的大小
    :param num_skips: 为对每个单词生成多少个样本，不能大于 skip_window 的两倍，而且必须是 num_skips 的整数倍
    :param skip_window: 单词最远可以联系的距离，设为 1 代表只能跟紧邻的两个单词生成样本
    :return:
    """
    global data_index
    assert batch_size % num_skips == 0 # batch_size 必须是 num_skips 的整数倍
    assert num_skips <= 2 * skip_window # num_skips 不能大于 skip_window 的两倍
    batch = np.ndarray(shape=(batch_size), dtype=np.int32)
    labels = np.ndarray(shape=(batch_size, 1), dtype=np.int32)
    span = 2 * skip_window + 1 # span 为对某个单词创建相关样本时会用到的单词数量
    buffer = collections.deque(maxlen=span) # 保留最后插入的 span 个数量

    for _ in range(span):
        buffer.append(data[data_index])
        data_index = (data_index + 1) % len(data)
    for i in range(batch_size // num_skips):
        # 第一层循环：每次循坏中对一个目标单词生成样本
        target = skip_window
        targets_to_avoid = [ skip_window ] # 生成样本时，需要避免的单词列表
        for j in range(num_skips):
            # 第二层循环: 每次循坏中对一个语境单词生成样本
            while target in targets_to_avoid:
                target = random.randint(0, span - 1)
            targets_to_avoid.append(target)
            batch[i * num_skips + j] = buffer[skip_window]
            labels[i * num_skips + j, 0] = buffer[target]
        buffer.append(data[data_index])
        data_index = (data_index + 1) % len(data)

    return batch, labels

batch, labels = generate_batch(batch_size=8, num_skips=2, skip_window=1)
for i in range(8):
    print(batch[i], reverse_dictionary[batch[i]], '->', labels[i, 0], reverse_dictionary[labels[i, 0]])
    # 3081 originated -> 12 as
    # 3081 originated -> 5240 anarchism
    # 12 as -> 3081 originated
    # 12 as -> 6 a
    # 6 a -> 12 as
    # 6 a -> 195 term
    # 195 term -> 6 a
    # 195 term -> 2 of

batch_size = 128
embedding_size = 128
skip_window = 1
num_skips = 2

valid_size = 16 # 用来抽取的验证单词数
valid_window = 100 # 指验证单词只从频数最高的 100 个单词中抽取
valid_examples = np.random.choice(valid_window, valid_size, replace=False)
num_sampled = 64 # 训练时用来做负样本的噪声单词的数量

graph = tf.Graph()
with graph.as_default():
    train_inputs = tf.placeholder(tf.int32, shape=[batch_size])
    train_labels = tf.placeholder(tf.int32, shape=[batch_size, 1])
    valid_dataset = tf.constant(valid_examples, dtype=tf.int32)

    with tf.device('/cpu:0'):
        embeddings = tf.Variable(
            tf.random_uniform([vocabulary_size, embedding_size], -1.0, 1.0))
        embed = tf.nn.embedding_lookup(embeddings, train_inputs)
        nce_weights = tf.Variable(
            tf.truncated_normal([vocabulary_size, embedding_size], stddev=1.0 / math.sqrt(embedding_size)))
        nce_biases = tf.Variable(tf.zeros([vocabulary_size]))
    loss = tf.reduce_mean(
        tf.nn.nce_loss(
            weights=nce_weights,
            biases=nce_biases,
            labels=train_labels,
            inputs=embed,
            num_sampled=num_sampled,
            num_classes=vocabulary_size
            ))

    optimizer = tf.train.GradientDescentOptimizer(1.0).minimize(loss)
    norm = tf.sqrt(tf.reduce_sum(tf.square(embeddings), 1, keep_dims=True))
    normalized_embeddings = embeddings / norm
    valid_embeddings = tf.nn.embedding_lookup(
        normalized_embeddings, valid_dataset)
    similarity = tf.matmul(valid_embeddings, normalized_embeddings, transpose_b=True)

    num_steps = 100001
    with tf.Session() as sess:
        tf.initialize_all_variables().run()
        print("Initialized")

        average_loss = 0
        for step in range(num_steps):
            batch_inputs, batch_labels = generate_batch(batch_size, num_skips, skip_window)
            feed_dict = {train_inputs: batch_inputs, train_labels: batch_labels}
            _, loss_val = sess.run([optimizer, loss], feed_dict=feed_dict)
            average_loss += loss_val

            if step % 2000 == 0:
                if step > 0:
                    average_loss /= 2000
                print("Average loss at step ", step, ": ", average_loss)
                average_loss = 0

            if step % 10000 == 0:
                sim = similarity.eval()
                for i in range(valid_size):
                    valid_word = reverse_dictionary[valid_examples[i]]
                    top_k = 8
                    nearest = (-sim[i, :]).argsort()[1:top_k + 1]
                    log_str = "Nearest to %s: " % valid_word
                    for k in range(top_k):
                        close_word = reverse_dictionary[nearest[k]]
                        log_str = "%s %s, " % (log_str, close_word)
                    print(log_str)
        final_embeddings = normalized_embeddings.eval()
```

一次训练的结果：

```
# output
Initialized
Average loss at step  0 :  308.616546631
Nearest to often:  strasbourg,  ritual,  pharsalus,  shulkhan,  demetrius,  diodorus,  cabbage,  guard,
Nearest to or:  wharf,  coordinates,  inevitable,  pinpoint,  taken,  businessman,  leases,  semiotics,
Nearest to of:  le,  masurian,  protestants,  medalist,  adonijah,  cantatas,  leeward,  unhelpful,
Nearest to two:  webzine,  equipping,  commissioned,  anecdotal,  denunciations,  demonolatry,  august,  disproved,
Nearest to that:  basset,  critics,  bight,  sagas,  paine,  imposing,  ebola,  mergesort,
Nearest to history:  karaca,  chmielnicki,  elaborated,  saunders,  radha,  zaragoza,  obstacle,  eureka,
Nearest to in:  laozi,  mcleod,  cabinda,  viceroys,  shou,  greeneville,  transpired,  hemiparesis,
Nearest to he:  laches,  lint,  beneficiary,  sandworms,  therefore,  dresden,  enclave,  disbanding,
Nearest to some:  spinners,  married,  forbidden,  left,  stored,  veered,  credible,  anil,
Nearest to eight:  starters,  intercession,  upload,  present,  lycanthropy,  gascony,  buccaneers,  dumas,
Nearest to united:  cris,  gynt,  northerners,  kenning,  undertake,  small,  planters,  propagandists,
Nearest to his:  laureates,  spousal,  insurgencies,  salian,  pointwise,  nicky,  jonas,  rakyat,
Nearest to these:  humanoids,  strangle,  inlays,  markov,  berzelius,  chassis,  bonneville,  tallis,
Nearest to five:  framers,  pharaoh,  mercosur,  pungent,  microscopic,  bretton,  arma,  xs,
Nearest to however:  pandora,  strip,  democrats,  fianc,  impressionist,  hanyu,  sells,  archeologist,
Nearest to into:  advanced,  misconception,  commoner,  irritant,  astonishingly,  hennecke,  humoral,  ibiblio,
Average loss at step  2000 :  113.289986176
Average loss at step  4000 :  52.5108610988
Average loss at step  6000 :  33.5151970199
Average loss at step  8000 :  23.5153739078
Average loss at step  10000 :  18.0684712229
Nearest to often:  artists,  ritual,  pharsalus,  implicit,  species,  guard,  computed,  ultimately,
Nearest to or:  and,  mya,  implicit,  taken,  cl,  in,  austin,  vs,
Nearest to of:  in,  and,  for,  implicit,  at,  austin,  nine,  with,
Nearest to two:  one,  austin,  UNK,  phi,  victoriae,  gland,  mathbf,  agave,
Nearest to that:  existence,  austin,  formations,  acted,  reginae,  could,  longstreet,  constructs,
Nearest to history:  austin,  authors,  factions,  reginae,  survived,  asterism,  chmielnicki,  none,
Nearest to in:  and,  of,  austin,  on,  with,  from,  to,  nine,
Nearest to he:  reginae,  dresden,  and,  it,  malls,  recordings,  enclave,  leave,
Nearest to some:  euclidean,  prove,  stored,  forbidden,  citizen,  married,  left,  agave,
Nearest to eight:  nine,  zero,  phi,  six,  reginae,  victoriae,  austin,  altenberg,
Nearest to united:  small,  agave,  confederation,  jinx,  normally,  course,  i,  bath,
Nearest to his:  the,  a,  deaf,  alkane,  android,  fresh,  indefinitely,  follow,
Nearest to these:  markov,  instance,  the,  humanoids,  gas,  monk,  america,  wins,
Nearest to five:  gland,  zero,  nine,  austin,  mathbf,  kind,  caria,  damage,
Nearest to however:  strip,  democrats,  theism,  austin,  gland,  supernova,  one,  generic,
Nearest to into:  for,  advanced,  misconception,  and,  altenberg,  mundane,  austin,  implicit,
Average loss at step  12000 :  13.8806200573
Average loss at step  14000 :  11.7359701315
Average loss at step  16000 :  9.98128035033
Average loss at step  18000 :  8.64614079773
Average loss at step  20000 :  7.87412105024
Nearest to often:  msg,  artists,  cabbage,  pharsalus,  strasbourg,  ritual,  implicit,  dolly,
Nearest to or:  and,  vs,  zero,  mya,  cl,  UNK,  in,  implicit,
Nearest to of:  in,  and,  for,  nine,  from,  implicit,  agouti,  with,
Nearest to two:  one,  three,  four,  zero,  seven,  eight,  six,  nine,
Nearest to that:  preprocessor,  and,  which,  could,  reginae,  computing,  in,  this,
Nearest to history:  austin,  zaragoza,  agouti,  equilibrium,  authors,  factions,  survived,  census,
Nearest to in:  and,  of,  with,  for,  from,  by,  on,  at,
Nearest to he:  it,  they,  dresden,  she,  reginae,  recordings,  malls,  and,
Nearest to some:  euclidean,  prove,  stored,  citizen,  forbidden,  the,  left,  ne,
Nearest to eight:  nine,  zero,  six,  seven,  three,  four,  five,  two,
Nearest to united:  small,  scrimmage,  jinx,  agave,  confederation,  undertake,  cliff,  vomiting,
Nearest to his:  the,  their,  a,  agouti,  s,  its,  abbess,  smuggling,
Nearest to these:  the,  agouti,  markov,  its,  instance,  eugenie,  humanoids,  monk,
Nearest to five:  nine,  zero,  eight,  seven,  six,  three,  four,  two,
Nearest to however:  strip,  theism,  yin,  democrats,  and,  rupert,  generic,  elagabalus,
Nearest to into:  for,  in,  and,  by,  as,  misconception,  to,  unto,
Average loss at step  22000 :  7.24987881541
Average loss at step  24000 :  7.0020082016
Average loss at step  26000 :  6.71827732325
Average loss at step  28000 :  6.22113520265
Average loss at step  30000 :  6.23344382131
Nearest to often:  msg,  artists,  known,  also,  bohemia,  cabbage,  usually,  dolly,
Nearest to or:  and,  vs,  mya,  cl,  agouti,  implicit,  akita,  the,
Nearest to of:  and,  in,  for,  from,  nine,  implicit,  eight,  containment,
Nearest to two:  three,  four,  one,  five,  six,  seven,  eight,  zero,
Nearest to that:  which,  this,  preprocessor,  abet,  because,  reginae,  norma,  it,
Nearest to history:  austin,  agouti,  saunders,  equilibrium,  zaragoza,  factions,  amalthea,  elaborated,
Nearest to in:  and,  on,  of,  from,  at,  nine,  with,  for,
Nearest to he:  it,  she,  they,  and,  reginae,  dresden,  there,  recordings,
Nearest to some:  many,  the,  prove,  euclidean,  their,  ne,  this,  stored,
Nearest to eight:  nine,  six,  seven,  four,  five,  three,  zero,  two,
Nearest to united:  small,  jinx,  scrimmage,  gestalt,  protectorate,  cb,  bath,  vomiting,
Nearest to his:  their,  the,  her,  s,  its,  a,  agouti,  gestae,
Nearest to these:  the,  agouti,  markov,  eugenie,  its,  some,  dosage,  many,
Nearest to five:  eight,  four,  six,  seven,  nine,  three,  zero,  two,
Nearest to however:  strip,  speedup,  theism,  but,  yin,  geralt,  rupert,  democrats,
Nearest to into:  in,  for,  from,  and,  to,  by,  on,  with,
Average loss at step  32000 :  5.90064259255
Average loss at step  34000 :  5.83000442636
Average loss at step  36000 :  5.68260792732
Average loss at step  38000 :  5.27819657373
Average loss at step  40000 :  5.48163154137
Nearest to often:  also,  usually,  msg,  cabbage,  bohemia,  known,  ultimately,  artists,
Nearest to or:  and,  agouti,  eight,  vs,  dasyprocta,  four,  implicit,  six,
Nearest to of:  in,  and,  from,  implicit,  for,  agouti,  containment,  eight,
Nearest to two:  three,  four,  six,  one,  seven,  five,  eight,  zero,
Nearest to that:  which,  this,  it,  preprocessor,  reginae,  abet,  because,  but,
Nearest to history:  austin,  agouti,  dnow,  saunders,  equilibrium,  elaborated,  amalthea,  torso,
Nearest to in:  at,  on,  and,  from,  with,  for,  of,  dasyprocta,
Nearest to he:  it,  she,  they,  there,  eventually,  who,  dresden,  cloaca,
Nearest to some:  many,  their,  the,  these,  prove,  this,  euclidean,  ne,
Nearest to eight:  nine,  six,  seven,  four,  five,  three,  zero,  dasyprocta,
Nearest to united:  jinx,  gestalt,  scrimmage,  protectorate,  bath,  small,  vomiting,  cb,
Nearest to his:  their,  her,  the,  its,  s,  agouti,  nuke,  smuggling,
Nearest to these:  some,  many,  markov,  the,  agouti,  eugenie,  its,  dosage,
Nearest to five:  four,  six,  seven,  eight,  three,  zero,  nine,  two,
Nearest to however:  but,  strip,  speedup,  theism,  pandora,  if,  yin,  rupert,
Nearest to into:  from,  for,  in,  by,  to,  with,  misconception,  irritant,
Average loss at step  42000 :  5.30737453246
Average loss at step  44000 :  5.31174786007
Average loss at step  46000 :  5.26442117739
Average loss at step  48000 :  5.03556689477
Average loss at step  50000 :  5.13681133306
Nearest to often:  also,  usually,  quasars,  still,  msg,  sometimes,  which,  known,
Nearest to or:  and,  agouti,  eight,  dasyprocta,  nine,  seven,  vs,  agave,
Nearest to of:  in,  and,  implicit,  nine,  for,  containment,  eight,  from,
Nearest to two:  three,  four,  one,  six,  five,  eight,  seven,  dasyprocta,
Nearest to that:  which,  this,  it,  because,  abet,  preprocessor,  but,  what,
Nearest to history:  radha,  austin,  torso,  agouti,  dnow,  saunders,  equilibrium,  elaborated,
Nearest to in:  on,  and,  at,  from,  of,  for,  dasyprocta,  nine,
Nearest to he:  it,  she,  they,  who,  there,  eventually,  malls,  dresden,
Nearest to some:  many,  these,  several,  their,  prove,  this,  the,  other,
Nearest to eight:  nine,  six,  seven,  four,  five,  three,  zero,  dasyprocta,
Nearest to united:  jinx,  gestalt,  scrimmage,  protectorate,  thibetanus,  vomiting,  cb,  bath,
Nearest to his:  their,  its,  her,  the,  s,  agouti,  escapement,  nuke,
Nearest to these:  some,  many,  the,  markov,  agouti,  eugenie,  its,  dosage,
Nearest to five:  four,  six,  three,  eight,  seven,  zero,  two,  nine,
Nearest to however:  but,  speedup,  strip,  theism,  pandora,  that,  rupert,  if,
Nearest to into:  from,  in,  for,  on,  by,  misconception,  with,  to,
Average loss at step  52000 :  5.18533633292
Average loss at step  54000 :  5.09767014468
Average loss at step  56000 :  5.05757240462
Average loss at step  58000 :  5.101632532
Average loss at step  60000 :  4.94643342322
Nearest to often:  also,  usually,  sometimes,  still,  quasars,  msg,  overriding,  ultimately,
Nearest to or:  and,  cebus,  tamarin,  agouti,  saguinus,  dasyprocta,  callithrix,  six,
Nearest to of:  in,  microcebus,  for,  nine,  microsite,  implicit,  tamarin,  callithrix,
Nearest to two:  three,  four,  five,  one,  six,  seven,  eight,  tamarin,
Nearest to that:  which,  this,  it,  but,  because,  tamarin,  preprocessor,  microcebus,
Nearest to history:  tamarin,  austin,  agouti,  microcebus,  radha,  ssbn,  michelob,  callithrix,
Nearest to in:  at,  on,  from,  and,  of,  microcebus,  ssbn,  tamarin,
Nearest to he:  it,  she,  they,  who,  there,  eventually,  cloaca,  malls,
Nearest to some:  many,  these,  several,  their,  other,  callithrix,  this,  prove,
Nearest to eight:  six,  nine,  seven,  five,  four,  zero,  three,  tamarin,
Nearest to united:  jinx,  gestalt,  protectorate,  scrimmage,  thibetanus,  serge,  cb,  vomiting,
Nearest to his:  their,  her,  its,  the,  michelob,  s,  tamarin,  agouti,
Nearest to these:  some,  many,  markov,  the,  other,  agouti,  dosage,  eugenie,
Nearest to five:  four,  six,  three,  eight,  seven,  zero,  nine,  two,
Nearest to however:  but,  tamarin,  speedup,  strip,  that,  if,  theism,  rupert,
Nearest to into:  from,  in,  to,  for,  with,  misconception,  on,  by,
Average loss at step  62000 :  4.81926014519
Average loss at step  64000 :  4.7984996841
Average loss at step  66000 :  4.98284959114
Average loss at step  68000 :  4.92162488329
Average loss at step  70000 :  4.79599044824
Nearest to often:  usually,  also,  sometimes,  still,  msg,  quasars,  generally,  which,
Nearest to or:  and,  cebus,  tamarin,  agouti,  saguinus,  dasyprocta,  callithrix,  michelob,
Nearest to of:  microcebus,  in,  nine,  microsite,  for,  cebus,  containment,  tamarin,
Nearest to two:  three,  four,  one,  six,  five,  seven,  eight,  tamarin,
Nearest to that:  which,  this,  what,  tamarin,  microcebus,  callithrix,  but,  however,
Nearest to history:  tamarin,  atal,  austin,  agouti,  radha,  microcebus,  michelob,  dnow,
Nearest to in:  at,  microcebus,  during,  from,  ssbn,  on,  tamarin,  dasyprocta,
Nearest to he:  it,  she,  they,  eventually,  who,  there,  cloaca,  malls,
Nearest to some:  many,  these,  several,  their,  other,  this,  callithrix,  the,
Nearest to eight:  nine,  six,  seven,  four,  five,  zero,  three,  tamarin,
Nearest to united:  jinx,  gestalt,  protectorate,  scrimmage,  serge,  thibetanus,  cb,  vomiting,
Nearest to his:  their,  her,  its,  the,  s,  michelob,  tamarin,  nuke,
Nearest to these:  some,  many,  markov,  such,  other,  its,  the,  eugenie,
Nearest to five:  four,  six,  three,  eight,  seven,  zero,  nine,  two,
Nearest to however:  but,  tamarin,  speedup,  if,  that,  although,  strip,  theism,
Nearest to into:  from,  in,  on,  up,  misconception,  with,  through,  irritant,
Average loss at step  72000 :  4.78560277796
Average loss at step  74000 :  4.77709698844
Average loss at step  76000 :  4.86786747253
Average loss at step  78000 :  4.79958838284
Average loss at step  80000 :  4.80194207835
Nearest to often:  usually,  also,  sometimes,  still,  generally,  commonly,  quasars,  typically,
Nearest to or:  and,  cebus,  tamarin,  agouti,  dasyprocta,  callithrix,  saguinus,  agave,
Nearest to of:  in,  containment,  microsite,  escuela,  microcebus,  nine,  including,  implicit,
Nearest to two:  three,  four,  six,  five,  seven,  one,  tamarin,  eight,
Nearest to that:  which,  this,  what,  however,  tamarin,  callithrix,  microcebus,  but,
Nearest to history:  tamarin,  atal,  escuela,  austin,  agouti,  pontificia,  torso,  microcebus,
Nearest to in:  at,  during,  on,  from,  microcebus,  ssbn,  of,  under,
Nearest to he:  it,  she,  they,  who,  there,  eventually,  cloaca,  malls,
Nearest to some:  many,  these,  several,  their,  other,  this,  callithrix,  the,
Nearest to eight:  nine,  seven,  six,  five,  four,  zero,  three,  tamarin,
Nearest to united:  jinx,  gestalt,  protectorate,  serge,  scrimmage,  pedantic,  vomiting,  planters,
Nearest to his:  their,  her,  its,  the,  s,  pontificia,  michelob,  tamarin,
Nearest to these:  some,  many,  such,  markov,  other,  several,  all,  the,
Nearest to five:  four,  six,  seven,  three,  eight,  nine,  zero,  two,
Nearest to however:  but,  tamarin,  speedup,  although,  that,  if,  faded,  theism,
Nearest to into:  from,  with,  in,  through,  on,  up,  misconception,  to,
Average loss at step  82000 :  4.80568939281
Average loss at step  84000 :  4.77090132213
Average loss at step  86000 :  4.74951952684
Average loss at step  88000 :  4.68855702603
Average loss at step  90000 :  4.75721267736
Nearest to often:  usually,  also,  sometimes,  still,  generally,  commonly,  quasars,  which,
Nearest to or:  and,  cebus,  tamarin,  callithrix,  saguinus,  agouti,  dasyprocta,  benelux,
Nearest to of:  in,  microcebus,  microsite,  including,  escuela,  recitative,  following,  for,
Nearest to two:  three,  four,  five,  six,  seven,  one,  eight,  tamarin,
Nearest to that:  which,  this,  what,  however,  but,  because,  tamarin,  microcebus,
Nearest to history:  karaca,  tamarin,  atal,  escuela,  austin,  agouti,  pontificia,  michelob,
Nearest to in:  at,  during,  microcebus,  of,  and,  on,  ssbn,  from,
Nearest to he:  it,  she,  they,  there,  who,  eventually,  later,  malls,
Nearest to some:  many,  these,  several,  their,  this,  callithrix,  any,  other,
Nearest to eight:  seven,  five,  six,  nine,  four,  three,  zero,  two,
Nearest to united:  gestalt,  jinx,  protectorate,  serge,  scrimmage,  molly,  classifying,  planters,
Nearest to his:  their,  her,  its,  the,  s,  michelob,  pontificia,  nuke,
Nearest to these:  some,  many,  such,  several,  markov,  all,  chassis,  they,
Nearest to five:  seven,  four,  eight,  six,  three,  nine,  two,  zero,
Nearest to however:  but,  tamarin,  although,  speedup,  that,  while,  faded,  if,
Nearest to into:  from,  through,  on,  in,  with,  misconception,  up,  during,
Average loss at step  92000 :  4.70002732158
Average loss at step  94000 :  4.62697509241
Average loss at step  96000 :  4.73610714591
Average loss at step  98000 :  4.61122905338
Average loss at step  100000 :  4.68292179108
Nearest to often:  usually,  also,  sometimes,  commonly,  still,  generally,  typically,  quasars,
Nearest to or:  and,  cebus,  tamarin,  callithrix,  dasyprocta,  agouti,  benelux,  michelob,
Nearest to of:  in,  microcebus,  nine,  escuela,  including,  implicit,  containment,  microsite,
Nearest to two:  three,  four,  five,  six,  one,  seven,  eight,  tamarin,
Nearest to that:  which,  this,  however,  what,  because,  but,  tamarin,  callithrix,
Nearest to history:  karaca,  tamarin,  atal,  escuela,  pontificia,  agouti,  austin,  troopers,
Nearest to in:  during,  at,  on,  from,  ssbn,  escuela,  microcebus,  under,
Nearest to he:  it,  she,  they,  there,  who,  eventually,  later,  malls,
Nearest to some:  many,  these,  several,  their,  any,  callithrix,  other,  all,
Nearest to eight:  seven,  nine,  six,  five,  four,  three,  zero,  tamarin,
Nearest to united:  jinx,  gestalt,  protectorate,  serge,  scrimmage,  cris,  of,  pedantic,
Nearest to his:  their,  her,  its,  the,  s,  michelob,  nuke,  pontificia,
Nearest to these:  some,  many,  several,  such,  all,  markov,  other,  those,
Nearest to five:  four,  six,  seven,  three,  eight,  nine,  two,  zero,
Nearest to however:  but,  tamarin,  although,  that,  speedup,  and,  while,  which,
Nearest to into:  from,  through,  on,  in,  with,  up,  during,  misconception,
```