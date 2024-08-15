# About DrawSequencer
ペンタブレットやマウスによってお絵かきツールのようにスペクトログラムを描画し、再生できるシーケンサーです。<br>
また、お絵かきした結果を画像（png）ファイルとして保存する、外部から画像ファイルを読み込んで再生する、音声（wav）データを読み込んで画像に変換する、などの機能があります。

# Content
DrawSeqencer<br>
├── readme.txt....このファイル<br>
├── drawSeqMain.scd....DrawSequencer実行用ファイル<br>
└── drawSeqOp.scd....画像エクスポート/インポート実行用ファイル<br>

# Install & Run
1) DrawSequencerは無料の音響生成ソフトウェアであるSuperCollider上で動作します。<br>
   以下の公式サイトからSuperColliderをダウンロードしてください。<br>
   https://supercollider.github.io
2) SuperColliderを起動し、画面上部メニューのFile>OpenからdrawSeqMain.scdを開く。
3) コード内にカーソルを置き、以下の操作によってコードを実行する。<br>
   macの場合→CommandとEnterを同時に押下／windowsの場合→CtrlとEnterを同時に押下
4) DrawSequencerのウインドウが開くので（数秒かかります）、マウスやペンタブレットを使って画面に描画してみる。<br>
  （※ペンタブレットの仕様や設定によってはスムーズに描画できない場合があります。ご了承ください)
5) ウインドウ右上の再生ボタンを押下すると音が再生される

# Control Menu
## color slider
スライダーで描画色の濃さを変更できる。音量の大きさと色の濃さは比例している。

## select menu
以下のプルダウンメニューからいくつかの操作が実行できます。<br>
※なお、範囲指定などでテキストボックスに数値を入力する際は、確定させるため必ず入力後にエンターキーを押してください！！！！<br>
<br>
**xy**<br>
xy選択時、テキストボックスにカーソルのxy座標が表示される。<br>
<br>
**copy**<br>
選択された範囲をバッファにコピーする。<br>
テキストボックス左にコピー範囲始点のx座標、テキストボックス右に終端のx座標を入力し、GOボタンを押下する。<br>
<br>
**del**<br>
選択された範囲を削除する。<br>
テキストボックス左に削除範囲始点のx座標、テキストボックス右に終端のx座標を入力し、GOボタンを押下する。<br>
<br>
**move**<br>
表示範囲を移動させる。テキストボックス左に移動するx座標を入力し、GOボタンを押下する。<br>
<br>
**load**<br>
画像ファイルを読み込む。<br>
読み込む画像ファイルはpng形式でimgフォルダ内に置く。<br>
テキストボックス左にファイル名、テキストボックス右に貼り付ける始点のx座標を入力し、GOボタンを押下する。<br>
画像ファイルの赤（Ｒ）＝スペクトルのパワー、緑（Ｇ）＝平均音量、青（Ｂ）＝位相情報として読み込みます。<br>
<br>
**save**<br>
画像ファイルをimgフォルダ内に保存する。<br>
テキストボックス左にファイル名を入力し、GOボタンを押下する。<br>
<br>
**add**<br>
空白の描画領域を追加する。<br>
テキストボックス左追加する横幅サイズを入力し、GOボタンを押下する。<br>
<br>
**pst**<br>
バッファにコピーしたデータを張り付ける。<br>
テキストボックス左にコピー貼り付け始点のx座標を入力し、GOボタンを押下する。<br>
<br>

# import wav file
音声ファイルをDrawSequencerで再生できる形式の画像に変換することができます。<br>
<br>
1)　変換したいwavファイルをwavフォルダ内に置く。<br>
2)  drawSeqOp.scdを開き、`var wavFileName = "test"; //←change here`のファイル名（test）部分を読み込みたいwavファイル名に変更する。<br>
3)  `//*****load execute No.1******`にカーソルを置き、実行する。（実行方法はdrawSeqMain.scdと同じ）<br>
4)  `//*****execute No.2******`にカーソルを置き、実行する。SuperColliderのポストウィンドウ（画面右下の窓部分）にdoneと表示されるまで待つ。<br>
5)  `var pngFileName = "test"; //←change here`に保存する画像ファイル名前を設定し、`//*****execute No.3******`にカーソルを置き、実行する。<br>
<br>
RGB情報を分けて画像ファイルを生成したい場合は、`//*****execute No.3******`の代わりに`//*****export img RGB******`を実行してください。<br>
<br>
# recording audio
再生している音を録音する。<br>
1)　`var fileName = "test"; //←change here`を変更し、録音するファイル名を設定する。<br>
2)  `//*****recording start******`にカーソルを置き、実行する。<br>
3)  録音を止めるには、`s.stopRecording;`にカーソルを置き、実行する。<br>

