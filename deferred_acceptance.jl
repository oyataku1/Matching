# 多対一のケース
function deferred_acceptance(s_prefs::Matrix{Int},
                             c_prefs::Matrix{Int},
                             caps::Vector{Int})
    
    s_num = length(s_prefs[1, :])#4
    c_num = length(c_prefs[1, :])#3 男４女３のケース
    freestudent = [i for i in 1:s_num] #[1,2,3,4]番がsingle
    s_unmatched = 0#自分とマッチの状態と定義
    c_unmatched = 0
    
    s_matched = [0 for i in 1:s_num]#[0,0,0,0]
    c_matched = [0 for i in 1:sum(caps)]#[0,0,0..] マッチしているのは自分
    target = [1 for i in 1:s_num]#[1,1,1,1] 各人が自分の第何希望の相手にプロポーズするか　はじめはみんな第一希望にプロポーズ
    
    n=length(c_prefs[1, :])
    indptr = Array(Int, n+1)
    indptr[1] = 1
    for i in 1:n
        indptr[i+1] = indptr[i] + caps[i]
    end

    
    while length(freestudent)>0#freeの学生がいなくなれば終了
        x = shift!(freestudent)#freestudentの初項 freestudentの要素は削除されていく　学生の番号
        y = s_prefs[:, x][target[x]]#学生[x]の次にトライする相手＝大学y
        
        
        if y == 0#f_matched[y]を使っているのでyが0だとindexが取り出せない　告白相手が自分
            s_matched[x]=0
            
        elseif y==1
            c_matched[indptr[y]:indptr[y+1]-1]#大学yのマッチ
            mathched_pref=[findfirst(c_prefs[:, y],c_matched[indptr[y]:indptr[y+1]-1][i]) for i in 1:caps[y]]#大学yのマッチを選好の順位に変換した配列
            maximum(mathched_pref)#現在のマッチで最低の学生の順位
            worststudent=c_matched[indptr[y]:indptr[y+1]-1][findfirst(mathched_pref,maximum(mathched_pref))]#マッチの中で一番評価の低い学生の番号
            if worststudent == 0#女性yの相手が自分自身の時
                if findfirst(c_prefs[:, y],worststudent)<findfirst(c_prefs[:, y],x)#現在のマッチ＞告白してきたx
                    push!(freestudent, x)#xをsinglemaleに戻す
                    target[x]+=1#次に好きな相手にtargetを変更
                else##今の相手<新たな男  ＝新たな男xとマッチするほうがいい f_matched[y] == 0なので捨てられる男はいない
                    c_matched[findfirst(c_matched[indptr[y]:indptr[y+1]-1],0)]=x
                    s_matched[x]=y#新しいマッチに変更
                end
            else#女性に相手誰かしらのマッチ相手がいる場合
                if findfirst(c_prefs[:, y],worststudent)<findfirst(c_prefs[:, y],x)#現在のマッチ＞告白してきたx
                    push!(freestudent, x)#xをsinglemaleに戻す
                    target[x]+=1#次に好きな相手にtargetを変更
                else#今の相手<新たな男  ＝新たな男xとマッチするほうがいい
                    push!(freestudent, worststudent)#捨てられる男をsingleに戻す
                    s_matched[worststudent]=0#捨てられた男は初期状態の自分とマッチに戻す
                    c_matched[findfirst(c_matched,worststudent)]=x
                    s_matched[x]=y#新しいマッチに変更
                end
            end    
            
        else#告白相手が自分以外、相手の選好を扱う
            c_matched[indptr[y]:indptr[y+1]-1]#大学yのマッチ
            mathched_pref=[findfirst(c_prefs[:, y],c_matched[indptr[y]:indptr[y+1]-1][i]) for i in 1:caps[y]]#大学yのマッチを選好の順位に変換した配列
            maximum(mathched_pref)#現在のマッチで最低の学生の順位
            worststudent=c_matched[indptr[y]:indptr[y+1]-1][findfirst(mathched_pref,maximum(mathched_pref))]#マッチの中で一番評価の低い学生の番号
            if worststudent == 0#女性yの相手が自分自身の時
                if findfirst(c_prefs[:, y],worststudent)<findfirst(c_prefs[:, y],x)#現在のマッチ＞告白してきたx
                    push!(freestudent, x)#xをsinglemaleに戻す
                    target[x]+=1#次に好きな相手にtargetを変更
                else##今の相手<新たな男  ＝新たな男xとマッチするほうがいい f_matched[y] == 0なので捨てられる男はいない
                    c_matched[sum(caps[1:y-1])+findfirst(c_matched[indptr[y]:indptr[y+1]-1],0)]=x
                    s_matched[x]=y#新しいマッチに変更
                end
        
            else#女性に相手誰かしらのマッチ相手がいる場合
                if findfirst(c_prefs[:, y],worststudent)<findfirst(c_prefs[:, y],x)#現在のマッチ＞告白してきたx
                    push!(freestudent, x)#xをsinglemaleに戻す
                    target[x]+=1#次に好きな相手にtargetを変更
                else#今の相手<新たな男  ＝新たな男xとマッチするほうがいい
                    push!(freestudent, worststudent)#捨てられる男をsingleに戻す
                    s_matched[worststudent]=0#捨てられた男は初期状態の自分とマッチに戻す
                    c_matched[findfirst(c_matched,worststudent)]=x
                    s_matched[x]=y#新しいマッチに変更
                end
            end    
        end
    end
    return s_matched, c_matched,indptr
end


# 一対一のケース
function deferred_acceptance(s_prefs::Matrix{Int}, c_prefs::Matrix{Int})
    caps = ones(Int, size(c_prefs, 2))
    s_matched, c_matched, indptr =
    deferred_acceptance(s_prefs, c_prefs, caps)
    return s_matched, c_matched
end