#module Optional
# 重要：このバージョンからKIKAのデータ順変更。初期値より先に構造を載せる。
#
#module KIKA
class Number::Game
  def set_block_group(gnr,boxes,bx,by,xmax,w,infile,sep)

      c = -1
      while c < @size
        while infile.gets && ( $_ =~ /^\s*#/ || $_ =~ /^\s*$/) ; end
        puts $_ if $dbg
        $_.chop.split(sep).each{|d| next if /\d+/ !~ d
          c += 1
          c += 1 if w[c].nil? ##
          puts "c=#{c} d=#{d}  @size=#{@size} " if $dbg
          puts "$kika: w[c] of c is #{c}, cell=#{w[c][0]},w[c][1]=#{w[c][1]}" if $dbg
          w[c][1] << d.to_i + gnr-1
        }
      end
      (gnr .. gnr+@n-1).each{|g| @groups[g] = Number::Group.new(self,g,:block)}
      gnr += @n
      gnr
  end
end
