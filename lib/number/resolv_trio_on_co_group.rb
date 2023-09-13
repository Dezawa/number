# frozen_string_literal: true

module Number
  # 解法
  # h or v と block の共通cell に着目。
  # h,v からみてそのcellにのみある数字は必ずそこにある
  # すなわち、blockでもそこだけにあることになる
  # block の他のcellにあるその数字は可能性から削除
  module ResolvTrioOnCoGroup
    def trio_on_co_group
      # return # prison(2,3)と等価?
      ret = ''
      @groups.each do |grp|
        # 値vの可能性をもつcellを得る
        valu_v_cell_ids = grp.cell_ids_rest_2_3_of_valu
        next if valu_v_cell_ids.empty?

        valu_v_cell_ids.each do |v, cell_ids|
          cogroup(cell_ids).each do |g|
            grp0 = @groups[g]
            # group g0 の valu_v_cell_ids 以外のcellから 値Vの可能性をなくす
            msg =  "## trio_on_co_group:group #{grp.g} V=#{v} cells=#{valu_v_cell_ids.join(',')}"
            if grp0.rm_ability(v, cell_ids, msg)
              @count[:trio_on_co_group] += 1
              return msg
            end
          end
        end
      end
      ret
    end
  end
end
