# coding: UTF-8
class Game #< Array
  def cogroup(cells)
    return [] if cells.size == 0
    cells[1..-1].inject(@cells[cells[0]].grpList) {|groups, c|   groups &= @cells[c].grpList}
  end

  def cocell(grps)
    return [] if grps.size < 2
    grps[1..-1].inject(groups[grps[0]].cellList){|cells,group| cells &= groups[group].cellList}
  end

  def fill?
    @cells.select{|cell| cell.v.nil? }.size == 0
  end
  def set_g(g); @g=g ; end
  def gout
    pp self.map{|grp| grp.ability.map{|abl| [grp.g,abl] if abl[0]>0}.compact}
  end

  def cout
    @cells.each{|cell| unless cell.v ; puts "#{cell.c} : #{cell.ability}" ;end }
  end

  ##############
  def rest_one
    # (1) 可能な値が一つだけになった　cell　を確定する
    # (2) ある値の可能性あるcellが一つになったら、そのcellを確定する

    sw = true
    ret = false
    while sw
      sw = false
      
     #(1) cell Ability
      @cells.each{|cell| sw |= cell.set_if_valurest_equal_1  }

      # (2) group ability [ 可能性cell数 , [cellNo,cellNo,, ], 値 ]
      @groups.each{|grp| sw |= grp.set_cell_if_some_value_s_ability_is_rest_one  }
      ret |= sw
    end
    ret
  end

  ########
  # 定員
  # N個のcellには v1,v2,,,vn なるN種の値しか入らないとき、
  # これらのcellが属するgroupの他のcell には　v1,v2,,,は入らない
  ########
  ###########################################################
  def teiin(v_num)
    # 残り可能性の数　2,,v_num なcellを拾い上げる
    # 同じ「残り可能性」なcellの組み合わせを探し、v_numあればhit
    @groups.each{|grp| 
      cells=grp.cellList.select{|c| @cells[c].valurest >1 && @cells[c].valurest<=v_num}
      cells.combination(v_num){|cc| 
        next if teiin_done[v_num].include? cc
        valus = cc.map{|c| @cells[c].ability}.inject([]){|val,abl| val |= abl}
        if valus.size == v_num #  このgrpでこれらのcellは vals が定員
          $count["teiin#{v_num}"] += 1
          # このcellを含むgrpの 他のcellにあるｖの可能性を消す
          cogroup(cc).each{|grp0| 
            @groups[grp0].rmAbility(valus,cc,
                                    "teiin#{v_num} grp #{grp.g} val #{valus} cell #{cc}")
          }
          teiin_done[v_num] << cc
          return true
        end
      } 
    } 
    return nil
  end # def teiin

  def teiin_done
    @teiin_done ||= Hash.new{|h,k| h[k]=[]}
  end
  ###########################################################
  # 予約席
  # あるgroupで 値  v1,v2,,,vn がr入り得るcellがN個だけだったら、
  # それらの cell にはn他の値は入れない
  #
  def reserv(v_num)
    # group において、可能性ある cell が v_num個以下の値を探す
    # それらの v_num個のcombinationのうち、
    # cell数が v_num 個であるものを得る
    # それらの cell ではそれらの値以外ははいらない
    ret = nil
    @groups.each{|group| 
      group.ability.combination_of_ability_of_rest_is_less_or_equal(v_num). # [[[2,[28,29],7], [2,[28,29],9]]]
      each{|abl_cmb|
        values,rm_cells = sum_of_cells_and_values(abl_cmb)
        next if teiin_done[v_num].include? rm_cells #value_cell[1]
        rm_value = @val - values
        if (rm_cells.map{|c| @cells[c].ability}.flatten - values).size > 0
          rm_cells.each{|c| 
            @cells[c].rmAbility(rm_value,
                                "reserve#{v_num} group #{group.g} cells#{rm_cells} v=#{values}")
          }
          $count["reserv#{v_num}"] += 1
          teiin_done[v_num] << rm_cells
          return true
        end
      }
    }
    return nil 
  end
  
  def sum_of_cells_and_values(abilitys)
        abilitys.inject([[],[]]){|vc,ac| # ac = [ count,[cells],value]
          vc[0] << ac.v #[2]  # value
          vc[1] |= ac.cellList #[1]  # cell
          vc
        }
  end
  ###########################################################
  
  # cell 1,2,3 のいずれかに数字 4 がはいる、と決まったら
  # 同じ行の 4、5、6、7、8、9 には 4の入る可能性は無くなる
  #
  # 1.各グループを調べ、のこり可能性が 2、3 となった値があるか調べる。
  # 2.その値をもつ cell のリストを得、
  # それ等を全て含むグループがあるか探す。
  # もしあれば、そのグループの他のcellから 可能性をなくす。
  def teiin5
    #return # teiin(2,3)と等価?
    ret = false
    @groups.each{|grp|
      (1..@n).each{|v| cnt=grp.ability[v].rest
        if cnt>1 && cnt < 4 ## -> 1.
          # 値vの可能性をもつcellを得る
          w = grp.ability[v].cellList
          s=w.size # 2 or 3
          # これと同じcellを全て含むグループを探す
          cogroup(w).each{|g| grp0=@groups[g]
            # group g0 の w 以外のcellから 値Vの可能性をなくす
            if grp0.rmAbility(v,w,"## teiin5:group #{grp.g} V=#{v} cells=#{w.join(",")}")
              $count[:teiin_5] += 1
              return true #ret = true
            end
            
          }
        end
      }
    }
    ret
  end # teiin5 
  

  def not_fill
    ret=nil
    (1..@cells.size-1).each{|c| @cells[c].ability[0]==0 && ret=true}
    ret
  end
  def fail
    @cells[1..-1].inject([]){|values,cell| values |= cell.ability}.size > 0
  end
  ########################### 上級モード Level-1
  ##########################
  # こういう関係では @ には 1,2 が入る。
  # 上中央のblockに注目すると、$$&%% のいずれかに 1,2が入る。
  #   @ には 1,2 のいずれかが入るから、&%%に1,2の両方が入ることはできない
  #   よって $$のどちらかに2,1が入ることになる。
  #   $$@で1,2がはいるから、| には1,2は入らない。
  # 同じように、+ には1,2は入れない。
  # ...$68...
  # ++.&%%++@
  # .6.$79..4
  # .8.@....5
  # .4.837..6
  # .3.695..7
  # .7.4....9
  # .5.|....8
  # ...|....3
  #
  # == 「こういう関係」
  # 残り可能性が２でかつ同じ値 V1,V2をもつcell A,B が対角線の位置にある
  # その長方形の残りの頂点 C を含む block G に着目
  # G上にあり、AC,BCのライン上にない 4つのcellのいずれもが、V1,V2の
  # 可能性も、決定もしていなければ、
  def curb #仮抑えのカーブ
    # 1. 残り可能性二つのcellを得る
    # 2. それらのcombinationを作り、
    # 3. そのうち 同じ数値の組み合わせのものを残す　cell A,B に v1,v2とする
    # 4. それらを対角線とする長方形の残りの頂点のcell C,Dを得る
    # 5. C,D 各々が属する block上で、AC,BC 上にないcell(4つ)を求め
    # 6. その4つのcellにV1,V2 がありうるか見る）
    ret = nil
    cell_combinations_rest_is_2_and_same_value.map{|cell_pair| # 1,2,3 残り可能性二つのcell
      #pp ["curb",cell_pair.map{|cell| cell.c}]
      theother_cells_of_rectangle_which_made_by_diagonal_of(cell_pair). # 4.その対角線のcell [0, 53]
      each{|c| next unless c
        values = cell_pair.first.ability
        next if have_cells_ability_values( # 6
                                     cells_not_on_the_V_or_H_group_of_the_group_of(c), # 5.
                                     values
                                     )
        # cell c と cell_nrs の共通group のcellから、v1,v2の可能性を削除する
        cell_pair.each{|cell|
          (ret |= groups[cogroup([c,cell.c]).first].
          rmAbility(values,cells_on_the_co_group_and_block(c,cell.c),
                    "curb: cogroup([#{c},#{cell.c}])=> #{groups[cogroup([c,cell.c]).first].g}"+
                    " 対角線[#{cell_pair[0].c},#{cell_pair[1].c}] values=#{values} " ))
        }
      }
    }
    nil
  end

  def cell_combinations_rest_is_2_and_same_value
    @cells.select{|cell| cell.valurest == 2}.
      combination(2).select{|cell1,cell2|
      # 3. そのうち 同じ数値の組み合わせのものを残す　cell1,2に　v1,v2とする
      # 4. そのうち 共通するgroupが無いものを残す
      #
      cell1.ability == cell2.ability &&
      (cell1.grpList & cell2.grpList).size == 0
    }
  end
  # 二つのcellを対角線とする長方形の残りのcell
  def theother_cells_of_rectangle_which_made_by_diagonal_of(cells)
    xross_cells = cells[0].grpList.product(cells[1].grpList).
      map{|grps| cocell(grps)}.flatten
    xross_cells.size ==2 ? xross_cells : []
  end


  def cells_not_on_the_V_or_H_group_of_the_group_of(cell)
    h,v,b = cells[cell].grpList.sort
    groups[b].cellList - groups[h].cellList-groups[v].cellList
  end

  # cellsのabilityに値v0,v1があるか
  def have_cells_ability_values(c_nrs,values)
    (c_nrs.inject([]){|ablty,c| ablty |= cells[c].vlist } & values).size > 0
  end

  # cell c と cell_nr の共通group のcell　でかつ c のblock上のもの
  def cells_on_the_co_group_and_block(c0,c1)
    (groups[cogroup([c0,c1]).first].cellList &
      groups[cells[c0].grpList.sort.last].cellList ) - [c0] + [c1]
  end



  ##########################
  # こういう関係で１があるとき、＊の位置に１があったらそれは削除
  # *.1..1..1
  # .........
  # ......... 
  # ..1.*1..1
  # .........
  # ......... 
  # ..1..1*.1
  # .........
  # .........   
  #
  # (1) :holizontal なgroupについて、値v　をとり得るcellの数が2,,@m であるグループを集める grps1
  #      grps1 = [ count, group ,[cells], [co_groups] ]  count <- cell数、co_?groups <- (2)
  # (2) そのcellを共有する:verticalなgroupを集める。[co_groups]
  # (3) それぞれの grps1から g_nums(2..@m)個づつの組み合わせをつくり cmb_grp
  # (4) co_groups のuniq がg_numsに等しい組み合わせを残す
  # 　　　複数のBOXな場合要吟味。重なる:block上に対象となるcellがあるという特殊な場合以外は行けるかも
  # 
  # (5) このco_groupsから値vの可能性を削除する。except cells
  # 
  # これを g_nums 2,,@m について繰り返し、:holizontal と :vertical を入れ替えて行う
  #     

  def crossTeiin
    ret = false
    h_v_table = [:holizontal , :vertical]
    h_v_table.each_with_index{|h_v,idx| v_h =  h_v_table[1-idx]  #　holizontal と :vertical について
      (1..@n).each{|v|                               # (1) 値v　をとり得る
        vsw=false
        grps1 = groups_remain_2_or_m_cells_of_value_is(h_v,v_h,v)
        #  [count , grp,  cells, co_groups]

        # (3) それぞれの cell grps1[2,g_nums]から g_numsつづつの組み合わせをつくり cmb_grp
        (2..@m).each{|g_nums|
          grps1.select{|grp| grp[0] <= g_nums }.combination(g_nums).each{| cmb_grp |

            # (4) co_groups のuniq がg_numsに等しい組み合わせを残す
            if (rm_grps=cmb_grp.map{|grp| grp[3] }.flatten.uniq).size == g_nums
              # (5) このco_groupsから値vの可能性を削除する。except cells
              #pp [v,cmb_grp[3]]
              except_cells = cmb_grp.map{|co_grp1| co_grp1[2] }.flatten.uniq
              rm_grps.each{|g| 
                if @groups[g].rmAbility(v, except_cells,
                                        "crossTeiin v=#{v}, grps=#{cmb_grp.map{|cg| cg[1].g}.join','}")
                  vsw = ret = $gsw = true
                end
              }
            end
          } # combination
        } # g_nums
        $count["crossTeiin"] += 1 if vsw
        #return true
      } # value
    } # h_v
    # これを g_nums 2,,@m について繰り返し、:holizontal と :vertical を入れ替えて行う
    #   
    $cross = nil
    ret #false
  end

  def groups_remain_2_or_m_cells_of_value_is(h_v,v_h,v)
    @groups.map{|grp| 
      if grp.type == h_v   and                   # 　　 :holizontal なgroupについて、
          (count = grp.ability[v].rest) <= @m and  #      値v　をとり得るcellの数が2,,@m である
          count > 1                              #      grp を集め
        # (2) そのcellを共有する:verticalなgroupを集める。[co_groups]
        cells = grp.ability[v].cellList
        co_groups = cells.map{|c| cogroup([c]).select{|g| @groups[g].type == v_h}.flatten}
        [count , grp,  cells, co_groups]
      end
    }.compact
  end

  ######################
  # 可能性が下のような場合は、+ は可能性落とす。
  # 0609-119
  #  @ 6 1 . 9 . 3 @ 5
  #  5 @ 9 3 6 1 @ 7 2
  #  3 7 2 8 4 5 9 1 6
  #  + 3 * 5 1 . @ 2 9
  #  7 2 * 6 3 9 1 @ 4               
  #  9 1 . . 2 8 . . 3
  #  2 * * 9 7 3 5 . 1
  #  . 9 7 . 5 6 . 3 8
  #  . 5 3 . 8 . . 9 7
  
  #そのための関数

  def highClass
    [ method(:crossTeiin) ,method(:curb)  ]
  end
end # Game
