#!/usr/bin/ruby1.9
# coding: utf-8
#  Id: $
# == ソフトの目的
# これは「数独」とか「ナンバープレース(ナンプレ)とか一般的に呼ばれているパズルの解法ソフトです。
#
# 数独のパズルにもいろいろな性格のものがありますが、このソフトが
# 解くのは、論理的に解けるもので、トライアンドエラーや総当たりで
# なければ解けないものは対象ではありません。
#   Internet上にあるパズルはトライアンドエラーが必要な質の悪いものが
#   多いように思われます。
#
# ただ単に解くのではなく、入門レベルの技で解く、初級レベルの技で解くなどと行い
# 問題のランク判定も試みようかと思います。
#
# == データ構造
# 1. /^\s*#/ な行はコメント行です。但し1行めに限り意味を持つことがあります。
# 2. 1行目は必ずコメント行にします。以下の文字列があると意味を持ちます。
#   NSP   : NoSPace これのみ他の文字列と併記可能です。9x9以下のときに有用です。
#         :  「データの数字(など)の間にデータ区切りの空白文字を入れない」べた打ちするということを意味します
# 3. 2行目はデータの構造を指定します。
#   9 または 16 または 25 : 9x9、16x16 25x25 の基本的な構造です
# 5. データ
#     3..5....6.7..  の様に 数値の指定のある所にはその数値を、そうでない所は数字以外を置く
#     ただし、アルファベットは予約。16x16 25x25の時に17進数、26進数を
# 使う可能性を残すので
#     「9x9 のパズルだから9x9の形で書く」必要はない。81個のデータがあれば良い
# 6. 各cellの値の間には NSP指定の時はべた打ち、無指定の時は空白文字を入れる
# 

$help ="
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
################
#####
require 'optparse'

require "stringio"

$LOAD_PATH.unshift(File.join(File.dirname(File.expand_path(__FILE__)),"number"))
$LOAD_PATH.unshift(File.dirname(File.expand_path(__FILE__)))
require 'num_ClassDefine'
require 'num_groups'
require 'num_resolver'
require 'num_make_waku_pform'
require 'group_ability'


require 'pp'

$count = Hash.new(0)
$LibDir = File.dirname(__FILE__)
$LOAD_PATH<< $LibDir +"/number"
$BAN=[]

###

###

###################################
#
# MAIN
#
###################################
def main(infile)
  # get game option 
  form,sep = get_paramater(infile)

  $game = Groupssub.new() rescue Game.new()
  # make Ban, cell, group
  $game.get_structure(infile,form,sep)

  # set initial data
  $game.get_initialdata(infile,sep)

  # Print initial
  $game.form.out($game.cells) unless $quiet

  #実行開始

  $game.resolve
  $game.form.out($game.cells) unless $quiet
  $game.cout if $cout
  #pp $game.fill?
  #pp $count
 # $game.form.out($game.cells)
  return  $game.fill?
end


def get_paramater(infile)
  ## get paramater file
  ##  # [NSP] [ARROW,,,,]
  ##  STD | 9, 12, 25, 9-3-2-3 ,,,
  ##
  infile.gets
  puts "$_= #{$_}" unless $quiet
  require 'num_arrow'  if $_ =~ /ARROW/
  require 'num_sum'    if $_ =~ /SUM/ 
  require 'num_kika'   if $_ =~ /KIKA/  
  require 'num_xross'  if $_ =~ /XROSS/
  require 'num_collor' if $_ =~ /COLOR/
  require 'num_hutougou' if $_ =~ /HUTOU/ 
  require 'num_diff'     if $_ =~ /DIFF/  
  require 'num_neighber' if $_ =~ /NEIGH/ 
  require 'num_odd'      if $_ =~ /ODD/   
  require 'num_cupcell'  if $_ =~ /CUP/   
  sep = $_ =~ /NSP/ ? ""   : /\s+/
  
  while infile.gets && ( $_ =~ /^\s*#/ || $_ =~ /^\s*$/) ; end
  puts "Structure #{$_}" unless $quiet
  relayList = $_.split
  form=relayList.shift
  form="9"  if form == "STD"
  
  [form,sep]  # return
end # of get_paramater

###########################
def try(grps)
  [0,1,2,3].each{|i| 
    $gsw=true
    while $gsw
      if $gout; puts "while loop top"; grps.gout;end
      $gsw=nil
      grps.highClass.each{|method|
#puts method.inspect
        sw = true
        while sw
          sw = nil
          grps.rest_one && $gsw=true && s１１w = true
          return true if grps.fill?
          if $gout; puts "rest one end"; grps.gout;end

          (2..4).each{|vnum|
            grps.reserv(vnum) && $gsw=true  && sw = true &&   grps.rest_one

            grps.teiin(vnum)  && $gsw=true  && sw = true && grps.rest_one
            return true if grps.fill?


            grps.teiin5       && $gsw=true  && sw = true &&   grps.rest_one
            if $gout ; puts "teiin #{vnum} end" ; grps.gout ;end
          }
          $gout && grps.gout
          ret = grps.optional_test  && gsw=true && sw = true
          ret && grps.rest_one
          return true if grps.fill?
          method.call && $gsw=true
        end
        $gout && grps.gout
        #i += 1
        puts "=======================#{i}===#{$gsw}=#{$optsw}======"
      }
      #        $gout && $game.gout
      #$game.cout
    end
  }
  grps.fill?
end # of resolv

def try_error
  if true
    (1..1).each{|i| # とりあえず、深さ1まで
      $try = nil

      # 未定cellのうち、可能性数がもっとも少ない cellについて、トライ＆エラー
      ## target t_
      t_cell= $game.cells.map{|cell| cell if cell.valurest>0 }.
      compact.sort{|a,b| a.valurest <=> b.valurest}[0]
      t_vlist = t_cell.vlist
      t_c = t_cell.c

      puts "Try & error cell #{t_c}:vlist #{t_cell.vlist.join(' ')}" unless $quiet
      $count["Try & error"] += 1

      t_vlist.each{|v|
        puts "Cell #{t_cell} value=#{v}" unless $quiet
        # 現環境の保存と複製
        $BAN << $game
        grps  = $game.copy
        grps.cells[t_c].set(v,"Try & error")
        return  true if try(grps) 
        $game = $BAN.pop
      }
    }
  end
end
