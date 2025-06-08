
data lindner (drop = lifepres);
    set dat;
    mort = lifepres = 0;
run;

/* 加权前按治疗组检查协变量均值 */
proc means data=lindner maxdec=2;
    class abcix;
    var mort cardbill stent height female diabetic acutemi ejecfrac ves1proc;
run;

/* 死亡率双稳健估计（DR）*/
ods graphics on;
proc causaltrt data=lindner method=aipw covdiffps poutcomemod nthreads=2;
    class abcix mort;
    psmodel abcix (ref='0') = stent height female diabetic acutemi ejecfrac ves1proc / plots=LPS;
    model mort (event='1') = stent height female diabetic acutemi ejecfrac ves1proc / dist=bin;
    bootstrap seed=1234 plots=hist(effect);
    output out=ps_weights ipw=ps_weight;
run;

/* 费用（cardbill）双重稳健估计（DR）*/
proc causaltrt data=lindner method=aipw covdiffps poutcomemod nthreads=2;
    class abcix mort;
    psmodel abcix (ref='0') = stent height female diabetic acutemi ejecfrac ves1proc;
    model cardbill = stent height female diabetic acutemi ejecfrac ves1proc;
    bootstrap seed=1234 plots=hist(effect);
run;

/* 基于倾向得分（PS）加权后检查协变量均值 */
proc means data=ps_weights maxdec=2;
    class abcix;
    var mort cardbill stent height female diabetic acutemi ejecfrac ves1proc;
    weight ps_weight;
run;

/* 死亡率逆概率加权（IPW）*/
proc causaltrt data=lindner method=ipw covdiffps;
    class abcix mort;
    psmodel abcix (ref='0') = stent height female diabetic acutemi ejecfrac ves1proc;
    model mort (event='1') / dist=bin;
    bootstrap seed=1234 plots=hist(effect);
run;

/* 费用（cardbill）逆概率加权（IPW）*/
proc causaltrt data=lindner method=ipw covdiffps;
    class abcix mort;
    psmodel abcix (ref='0') = stent height female diabetic acutemi ejecfrac ves1proc;
    model cardbill;
    bootstrap seed=1234 plots=hist(effect);
run;

/* 死亡率回归调整 */
proc causaltrt data=lindner method=regadj;
    class abcix mort;
    psmodel abcix (ref='0');
    model mort (event='1') = stent height female diabetic acutemi ejecfrac ves1proc / dist=bin;
    bootstrap seed=1234 plots=hist(effect);
run;

/* 费用（cardbill）回归调整 */
proc causaltrt data=lindner method=regadj;
    class abcix mort;
    psmodel abcix (ref='0');
    model cardbill = stent height female diabetic acutemi ejecfrac ves1proc;
    bootstrap seed=1234 plots=hist(effect);
run;
