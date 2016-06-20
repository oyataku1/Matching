function deferred_acceptance(m_prefs, f_prefs)
    
    m_num = length(m_prefs[1, :])#4
    f_num = length(f_prefs[1, :])#3 男４女３のケース
    singlemale = [i for i in 1:m_num] #[1,2,3,4]番がsingle
    m_unmatched = 0#自分とマッチの状態と定義
    f_unmatched = 0
    
    m_matched = [0 for i in 1:m_num]#[0,0,0,0]
    f_matched = [0 for i in 1:f_num]#[0,0,0] マッチしているのは自分
    
    target = [1 for i in 1:m_num]#[1,1,1,1] 各人が自分の第何希望の相手にプロポーズするか　はじめはみんな第一希望にプロポーズ
    
    while length(singlemale)>0#singleの男性がいなくなれば終了
        x = shift!(singlemale)#singlemaleの初項 singleの要素は削除されていく　男の番号
        y = m_prefs[:, x][target[x]]#男[x]の次に告白する相手＝女性y
        
        if y == 0#f_matched[y]を使っているのでyが0だとindexが取り出せない　告白相手が自分
            m_matched[x]=0
            
        else#告白相手が自分以外
            if f_matched[y] == 0#女性yの相手が自分自身の時
                if findfirst(f_prefs[:, y],f_matched[y])>findfirst(f_prefs[:, y],x)#現在のマッチ＞告白してきたx
                    push!(singlemale, x)#xをsinglemaleに戻す
                    target[x]+=1#次に好きな相手にtargetを変更
                else##今の相手<新たな男  ＝新たな男xとマッチするほうがいい f_matched[y] == 0なので捨てられる男はいない
                    f_matched[y]=x
                    m_matched[x]=y#新しいマッチに変更
                end
        
            else#女性に相手誰かしらのマッチ相手がいる場合
                if findfirst(f_prefs[:, y],f_matched[y])>findfirst(f_prefs[:, y],x)#現在のマッチ＞告白してきたx
                    push!(singlemale, x)#xをsinglemaleに戻す
                    target[x]+=1#次に好きな相手にtargetを変更
                else#今の相手<新たな男  ＝新たな男xとマッチするほうがいい
                    push!(singlemale, f_matched[y])#捨てられる男をsingleに戻す
                    m_matched[f_matched[y]]=0#捨てられた男は初期状態の自分とマッチに戻す
                    f_matched[y]=x
                    m_matched[x]=y#新しいマッチに変更
                end
            end    
        end
    end
    return m_matched, f_matched
end