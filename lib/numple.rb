#!/usr/bin/env ruby
# frozen_string_literal: true

# == ソフトの目的
# これは「数独」とか「ナンバープレース(ナンプレ)とか一般的に呼ばれているパズルの解法ソフトです。
#
# 数独のパズルにもいろいろな性格のものがありますが、このソフトが
# 解くのは、論理的に解けるもので、トライアンドエラーや総当たりで
# なければ解けないものは対象ではありません。
#   Interneta上にあるパズルはトライアンドエラーが必要な質の悪いものが
#   多いように思われます。
#
# 隔月雑 ナンプレファン をターゲットにしていたので、ナンプレファンにある
# 色物も対象となっています。
#   対角線、幾何、一つ違い、アロー、サム、セル、6X6、12x12、16x16、25x25
#   9x9をいくつか組み合わせたもの などです
#
# == データ構造
# 1. /^\s*#/ な行はコメント行です。但し1行めに限り意味を持つことがあります。
# 2. 1行目は必ずコメント行にします。以下の文字列のどれかがあると意味を持ちます。
#   ARROW : 色物 アロー の指定
#   SUM   : 色物 サム の指定
#   HUTOU : 色物 不等号 の指定
#   DIFF  : 色物
#   NEIGH : 色物 二つ違い
#   ODD   : 色物 偶奇
#   KIKA  : 色物 幾何
#   XROSS : 色物 クロス
#   CUP   : 色物
#   COLOR : 色物 カラー
# 3. 2行目はデータの構造を指定します。
#   9 または 16 または 25 : 9x9、16x16 25x25 の基本的な構造です
#   2x3、3x2、3x4 または 4x3 : 6x6 または 12x12 のパズルです。
#                            : 6x6 の中身が 縦2横3のとき 2x3と表記します
#   9-n±m±。。。。  : 9x9の基本形を1段めn個2段めｍ個、、、並べたもの。
#                     : nの段とmの段の基本形はお互いに3x3ずつ重なっている。
#                     : n,m間が "-" のときはmの段は右にずれ、"+"の時は左にずれる
# 4. 色物の構造指定
#      クロス は指定不要。その他はデータの前に構造を指定する。
# 5. データ
#     3..5....6.7..  の様に 数値の指定のある所にはその数値を、そうでない所は数字以外を置く
#     ただし、"e","o" はそのcellを偶数指定、奇数指定する。
#     「9x9 のパズルだから9x9の形で書く」必要はない。81個のデータがあれば良い
# 6. 各cellの値の間には空白文字を入れる。ただし最大数字が9以下の場合は空白なしベタ打ちでもよい。
#

require 'English'
@help = "
   -S   統計出力   どのテクニックが何回使われたか
   -s   構造出力   groupに属するcell、cellが属するgroup、arrow
   -v   おしゃべり 状況変更毎に表示。 テクニック使用、cell確定
   -V   大声       -vに加え、cell,groupの可能性が変更されたとき
   -T   経過出力   loop毎に途中経過出力
   -c   cell出力   cellのability出力。いつにするかなぁ、、、-c[12345]とかにするか？
   -g   group出力  groupのability出力
   -d[1..9]       debagu用
   -t             test用
   -1             ハイレベル解法

"

# 使い方
# numple = Numplre.new(infile)
#  infile :: STDIN :: 起動後keyBoad もしくは pipe で dataを流し込む
#         :: IO :: data file を open、もしくは data文字列を StringIOにしたもの
#         :: String  data file名
# numple.resolve
# puts numple.output_form  解出力
# puts numple.cell_out     Cellの残された可能性出力
#      numple.cell_ability  Cellの残された可能性のデータ
# puts numple.output_statistics  統計出力

################
#####
require 'optparse'
require 'stringio'
require 'net/smtp'

# $LOAD_PATH.unshift(File.join(File.dirname(File.expand_path(__FILE__)),"number"))
# $LOAD_PATH.unshift(File.dirname(File.expand_path(__FILE__)))
require_relative 'number/game'
require_relative 'number/cell'
require_relative 'number/group'
require_relative 'number/form'
require_relative 'number/box'

require_relative 'number/resolver'
require_relative 'number/make_waku_pform'
require_relative 'number/group_ability'

# ナンプレのフロントエンド
class Numple
  attr_reader :infile, :game, :option

  def initialize(infile, option: {})
    @infile = infile.is_a?(String) ? File.open(infile) : infile
    @option = option
  end

  def resolve
    game = create_game
    game.resolve
  end

  def output_form
    game.output_form  # 解出力
  end

  def cell_out
    game.cell_out     # Cellの残された可能性出力
  end

  def output_statistics
    game.output_statistics # 統計出力
  end

  def create_game
    @game = Number::Game.create(infile, option: option)
  end
end

################# end of Numple ###
# rubocop: disable Metrics/MethodLength
def options
  opt = OptionParser.new
  option = {}
  # opt.on('-q') {|v| @quiet = v }
  opt.on('-S') { |v| option[:stat] = v }
  opt.on('-s') { |v| option[:strct] = v }
  opt.on('-v') { |v| option[:verb] = v }
  opt.on('-V') { |v| option[:Verb] = v }
  opt.on('-T') { |v| option[:table] = v }
  opt.on('-t') { |v| option[:test] = v }
  opt.on('-c') { |v| option[:cout] = v }
  opt.on('-g') { |v| option[:gout] = v }
  opt.on('-d') { |v| option[:dbg] = v }
  opt.on('-m') { |v| option[:mail] = v }
  # opt.on('- ""') {|v| $= v }
  # opt.on('- ""') {|v| $= v }
  @level = 0
  opt.on('-1') { |_v| option[:level] = 1 }
  opt.on('-h') do |_v|
    puts @help
    exit(0)
  end
  opt.parse!(ARGV)
  return option unless option[:dbg]

  option
end
# rubocop: enable Metrics/MethodLength

# ###############################################3
# DO Main
################################################
if /numple.rb$/ =~ $PROGRAM_NAME
  option = options
  if ARGV.size.positive?
    ARGV.each do |infile|
      puts "############ #{infile} #######"
      numple = Numple.new(infile, option: option)
      warn "FAIL #{infile} " unless numple.resolve
      puts numple.output_form # 解出力
      puts numple.cell_out if option[:cout] # Cellの残された可能性出力
      # numple.cell_ability  #Cellの残された可能性のデータ
      puts numple.output_statistics if option[:stat] # 統計出力
      puts
    end
  else
    numple = Numple.new($stdin, option: option)
    numple.resolve
    puts numple.output_form # 解出力
    puts numple.cell_out if option[:cout] # Cellの残された可能性出力
    # numple.cell_ability  #Cellの残された可能性のデータ
    puts numple.output_statistics if @stat # 統計出力
    puts
  end
end
#   if $mail
#     # メールから問題を読み、答えをメールで返す
#     # Subjectにoption, body に問題

#     ## メールを一つ読み、解析する
#     $/ = ""
#     h = {}
#     header = gets.split(/[\n\r]+/)
#     while head = header.shift
#       if /^(\w+):\s*(.*)$/ =~ head
#         tag = $1 ;h[$1] = $2
#       elsif tag and /^\s/ =~ head
#         h[tag] += head
#       end
#     end
#     # Make response header
#     res = "Subject: Re: #{h['Subject']}\n"+
#       "In-Reply-To: #{h['Message-Id']}\n"+
#       "From: Number Place <number@aliadne.net>\n" +
#       "To: #{h['From']}"+
#       "Date: "+Time.now.strftime('%a,%d %b %Y %T')+"\n\n"
#     $/ = "\n"
#     $of = StringIO.new("", 'r+')
#     main($stdin)
#     $of.printf "\n"
#     $count.each{|l,v| $of.printf "Stat: %-10s %3d\n",l,v}
#     $of.rewind
#     $/ = nil
#     #puts $of.gets

#     Net::SMTP.start('ww3.aliadne.net', 25,"ww3.aliadne.net") {|smtp|
#       smtp.send_message(res+$of.gets, 'number@aliadne.net',h['From'])
#     }

# $Log: number.rb,v $
# Revision 1.17  2012-09-07 00:54:56  dezawa
# *** empty log message ***
#
# Revision 1.16  2012-09-04 13:54:56  dezawa
# GroupsをGameに改名。をにした
#
# Revision 1.15  2012-09-04 09:22:53  dezawa
# rest_oneの処理をCellとGroupに移動
#
# Revision 1.14  2012-09-03 22:58:34  dezawa
# cueb実装。ゴミとりしていない
#
# Revision 1.13  2012-09-01 11:50:34  dezawa
# loadpath追加
#
# Revision 1.12  2012-08-31 07:12:54  dezawa
# CUPCELLの
#
# Revision 1.11  2012-08-31 02:36:31  dezawa
# *** empty log message ***
#
# Revision 1.10  2012-08-30 21:38:21  dezawa
# CUPCELLできた
#
# Revision 1.9  2012-08-27 11:10:43  dezawa
# KIKAをポリモーフィックに
#
# Revision 1.8  2012-08-27 10:32:19  dezawa
# をなくした
#
# Revision 1.7  2012-08-27 10:20:07  dezawa
# Try&error
#
# Revision 1.6  2012-08-27 09:05:51  dezawa
# *** empty log message ***
#
# Revision 1.5  2012-08-26 00:34:09  dezawa
# CUPは未完のようだ
#
# Revision 1.4  2012-08-25 13:52:52  dezawa
# num_ClassDefine.rb
#
# Revision 1.3  2012-08-24 13:28:35  dezawa
# *** empty log message ***
#
# Revision 1.2  2012-08-22 12:13:28  dezawa
# class GROUPS を ARRAYの子でなくした
#
# Revision 1.45  2011-02-17 02:41:24  dezawa
# color release
#
# Revision 1.44  2011-01-12 08:29:11  dezawa
# remove debug pp
#
# Revision 1.43  2011-01-12 08:26:46  dezawa
# mail respomse
#
# Revision 1.42  2010-12-13 05:44:58  dezawa
# fix curv
#
# Revision 1.41  2010-12-13 02:29:42  dezawa
# reserv is addes, BUG fix
#
# Revision 1.40  2010-12-12 12:02:24  dezawa
# co group BUG fix
#
# Revision 1.39  2010-12-07 22:19:21  dezawa
# Remake CalssDefine: fix teiin5
#
# Revision 1.38  2010-12-07 11:18:01  dezawa
# fix rmCellAbility
#
# Revision 1.37  2010-12-07 07:39:16  dezawa
# Boke! removed num_ClassDefine.rb without cvs add
# remaking. tmp ci: just rest_one
#
# Revision 1.36  2010-12-06 08:37:27  dezawa
# Marge Remake
#
# Revision 1.35.2.10  2010-11-27 07:57:42  dezawa
# coding UTF-8
#
# Revision 1.35.2.9  2010-11-26 10:45:11  dezawa
# cupcell fix
#
# Revision 1.35.2.8  2010-11-25 12:33:27  dezawa
# neighber fix
#
# Revision 1.35.2.7  2010-11-25 11:43:34  dezawa
# set try&error 1level
#
# Revision 1.35.2.6  2010-11-23 12:47:22  dezawa
#
