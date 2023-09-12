# frozen_string_literal: true

module Number
  # 解法
  module ResolvTrioOnCoGroup
    def trio_on_co_group
      # return # prison(2,3)と等価?
      ret = ''
      @groups.each do |grp|
        (1..game_scale).each do |v|
          cnt = grp.ability[v].rest
          next unless cnt > 1 && cnt < 4 ## -> 1.

          # 値vの可能性をもつcellを得る
          w = grp.ability[v].cell_ids
          s = w.size # 2 or 3
          # これと同じcellを全て含むグループを探す
          cogroup(w).each do |g|
            grp0 = @groups[g]
            # group g0 の w 以外のcellから 値Vの可能性をなくす
            if grp0.rm_ability(v, w, "## trio_on_co_group:group #{grp.g} V=#{v} cells=#{w.join(',')}")
              @count[:trio_on_co_group] += 1
              return "## trio_on_co_group:group #{grp.g} V=#{v} cells=#{w.join(',')}"
            end
          end
        end
      end
      ret
    end
  end
end
