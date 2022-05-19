# 编译原理

## 文法

文法为描述语言的生成方式。定义为四元组 $G=(V_N,V_T,P,S)$，其中分别表示：

- $V_n$ 非终结符号、语法实体、变量集
- $V_T$ 终结符号集合
- $P$ 规则集合
- $S$ 作为识别符号或开始符号的一个非终结符，至少要在一条产生式中作为左部出现

文法还有如下的性质：

- $V_N,V_T,P$ 都是非空有限集合
- $V_N\cap V_T=\empty$
- $V\coloneqq V_N\cup V_T$ 称为字母表

定义 $X^*$ 表示字母集合 $X$ 中的元素组合而成的词的集合，此外定义 $\varepsilon$ 表示空词，$X^+\coloneqq X^*\backslash \{\varepsilon\}$。则所谓文法的规则是形如 $a\to b$ 或写作 $a\Coloneqq b$ 的有序对，其中 $a\in V^+, b\in V^*$，$a,b$ 分别被成为公式的左部和右部。

定义**直接推导**：

若给定文法 $G$ 如上定义，且有 $v,w$ 使得 $v=\gamma\alpha\delta, w=\gamma\beta\delta$，且存在规则 $\alpha\to \beta$，则称 $v$ 直接推导到 $w$，记作 $v\Rightarrow w$，也称 $w$ 直接归约到 $v$。若存在直接推导链 $v\Rightarrow v_1\Rightarrow\cdots\Rightarrow v_n$，则称 $v$ 推导到 $v_n$，记作 $v\overset{*}\Rightarrow$