
data lindner (drop = lifepres);
    set dat;
    mort = lifepres = 0;
run;

/* ��Ȩǰ����������Э������ֵ */
proc means data=lindner maxdec=2;
    class abcix;
    var mort cardbill stent height female diabetic acutemi ejecfrac ves1proc;
run;

/* ������˫�Ƚ����ƣ�DR��*/
ods graphics on;
proc causaltrt data=lindner method=aipw covdiffps poutcomemod nthreads=2;
    class abcix mort;
    psmodel abcix (ref='0') = stent height female diabetic acutemi ejecfrac ves1proc / plots=LPS;
    model mort (event='1') = stent height female diabetic acutemi ejecfrac ves1proc / dist=bin;
    bootstrap seed=1234 plots=hist(effect);
    output out=ps_weights ipw=ps_weight;
run;

/* ���ã�cardbill��˫���Ƚ����ƣ�DR��*/
proc causaltrt data=lindner method=aipw covdiffps poutcomemod nthreads=2;
    class abcix mort;
    psmodel abcix (ref='0') = stent height female diabetic acutemi ejecfrac ves1proc;
    model cardbill = stent height female diabetic acutemi ejecfrac ves1proc;
    bootstrap seed=1234 plots=hist(effect);
run;

/* ��������÷֣�PS����Ȩ����Э������ֵ */
proc means data=ps_weights maxdec=2;
    class abcix;
    var mort cardbill stent height female diabetic acutemi ejecfrac ves1proc;
    weight ps_weight;
run;

/* ����������ʼ�Ȩ��IPW��*/
proc causaltrt data=lindner method=ipw covdiffps;
    class abcix mort;
    psmodel abcix (ref='0') = stent height female diabetic acutemi ejecfrac ves1proc;
    model mort (event='1') / dist=bin;
    bootstrap seed=1234 plots=hist(effect);
run;

/* ���ã�cardbill������ʼ�Ȩ��IPW��*/
proc causaltrt data=lindner method=ipw covdiffps;
    class abcix mort;
    psmodel abcix (ref='0') = stent height female diabetic acutemi ejecfrac ves1proc;
    model cardbill;
    bootstrap seed=1234 plots=hist(effect);
run;

/* �����ʻع���� */
proc causaltrt data=lindner method=regadj;
    class abcix mort;
    psmodel abcix (ref='0');
    model mort (event='1') = stent height female diabetic acutemi ejecfrac ves1proc / dist=bin;
    bootstrap seed=1234 plots=hist(effect);
run;

/* ���ã�cardbill���ع���� */
proc causaltrt data=lindner method=regadj;
    class abcix mort;
    psmodel abcix (ref='0');
    model cardbill = stent height female diabetic acutemi ejecfrac ves1proc;
    bootstrap seed=1234 plots=hist(effect);
run;
