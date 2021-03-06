\documentclass{beamer}

\usetheme{Antibes}

\usepackage{agda}

\usepackage{amssymb}
\usepackage{stmaryrd}
\usepackage{bbm}
\usepackage[greek,english]{babel}

\usepackage{ucs}
\usepackage{autofe}

\DeclareUnicodeCharacter{8336}{\ensuremath{_a}}
\DeclareUnicodeCharacter{8788}{:=}
\DeclareUnicodeCharacter{8799}{\ensuremath{\stackrel{?}{=}}}

\usepackage{graphicx}
\graphicspath{ {../images/} }

\AtBeginSection[]{
  \begin{frame}
  \vfill
  \centering
  \begin{beamercolorbox}[sep=8pt,center,shadow=true,rounded=true]{title}
    \usebeamerfont{title}\insertsectionhead\par%
  \end{beamercolorbox}
  \vfill
  \end{frame}
}

\setlength{\leftskip}{0cm}
\setlength{\mathindent}{0pt}

\renewenvironment{code}
{\noindent\ignorespaces\advance\leftskip\mathindent\AgdaCodeStyle\pboxed}
{\endpboxed\par\noindent\ignorespacesafterend}

\title{A (Toy) Verified Compiler in Agda}

\author{Natalie Perna\\
  pernanm@mcmaster.ca}

\institute{Department of Computing and Software\\
    McMaster University}

\date{April 11, 2016}

\begin{document}

\begin{frame}
    \titlepage
\end{frame}

\begin{frame}{Outline}
    \tableofcontents
\end{frame}

\iffalse
\begin{code}
module Presentation2 where

open import Data.Fin hiding (_+_;_-_;_≤_;_<_)
open import Data.Nat hiding (_+_;_≤_;_≥_;_<_;_>_;_≟_;_≤?_)
open import Data.Integer renaming (
  _+_ to plus;
  _*_ to times;
  -_ to negative;
  _-_ to minus;
  _≤_ to leq)
open import Data.Vec
open import Data.Bool hiding (if_then_else_;_≟_) renaming (_∧_ to and; _∨_ to or)
open import Relation.Nullary.Decidable
\end{code}
\fi

\section{Syntax}

\begin{frame}
The abstract syntax of expressions are based on the While\textsuperscript{int} programming language from RSD.

\includegraphics[width=\textwidth]{fig53.png}

\end{frame}

\begin{frame}[fragile]
\begin{code}
data Exp-int (n : ℕ) : Set where
  Lit : ℤ → Exp-int n
  Var : Fin n → Exp-int n
  -_ : Exp-int n → Exp-int n
  _+_ : Exp-int n → Exp-int n → Exp-int n
  _-_ : Exp-int n → Exp-int n → Exp-int n
  _×_ : Exp-int n → Exp-int n → Exp-int n
\end{code}
\end{frame}

\begin{frame}[fragile]
\begin{code}
data Exp-bool (n : ℕ): Set where
  ⊤ : Exp-bool n
  ⊥ : Exp-bool n
  ¬_  : Exp-bool n → Exp-bool n
  _∧_ : Exp-bool n → Exp-bool n → Exp-bool n
  _∨_ : Exp-bool n → Exp-bool n → Exp-bool n
  _≡_ : Exp-int n → Exp-int n → Exp-bool n
  _≠_ : Exp-int n → Exp-int n → Exp-bool n
  _<_ : Exp-int n → Exp-int n → Exp-bool n
  _≤_ : Exp-int n → Exp-int n → Exp-bool n
  _>_ : Exp-int n → Exp-int n → Exp-bool n
  _≥_ : Exp-int n → Exp-int n → Exp-bool n
\end{code}
\end{frame}

\begin{frame}
The command syntax is similarly based based on the While\textsuperscript{int} programming language from RSD.

\includegraphics[width=\textwidth]{fig51.png}
\end{frame}

\begin{frame}[fragile]
\begin{code}
data Comm (n : ℕ) : Set where
  skip : Comm n
  _,_  : Comm n → Comm n → Comm n
  _≔_ : Fin n → Exp-int n → Comm n
  if_then_else_ : Exp-bool n → Comm n → Comm n → Comm n
  while_do_ : Exp-bool n → Comm n → Comm n
\end{code}
\end{frame}

\iffalse
\begin{code}
infixl 5 _⊢_⇓ₐ_
infixl 5 _⊢_⇓₀_
infixl 5 _⊢_⇓_
\end{code}
\fi

\section{Semantics}

\begin{frame}
Semantics of integer expressions of While\textsuperscript{int} are defined in RSD as follows:

The functional $\llbracket \cdot \rrbracket$ maps every $e \in Exp_{int}$ to a function $\llbracket e \rrbracket : \Sigma \to \mathbb{Z}$.

\includegraphics[width=\textwidth]{def53a.png}

\end{frame}

\begin{frame}[fragile,allowframebreaks]
\begin{code}
data _⊢_⇓ₐ_ {n : ℕ} ( E : Vec ℤ n) : Exp-int n → ℤ → Set where
  lit-e   : ∀{n}

            -------------
          → E ⊢ Lit n ⇓ₐ n

  var-e   : ∀{n}{x}

          → E [ x ]= n
            -------------
          → E ⊢ Var x ⇓ₐ n
\end{code}

\framebreak

\begin{code}
  negative-e : ∀{e}{v}

          → E ⊢ e ⇓ₐ v
            ---------------------
          → E ⊢ - e ⇓ₐ negative v

  plus-e  : ∀{e₁ e₂}{v₁ v₂}

          → E ⊢ e₁ ⇓ₐ v₁
          → E ⊢ e₂ ⇓ₐ v₂
            ---------------------
          → E ⊢ e₁ + e₂ ⇓ₐ plus v₁ v₂
\end{code}

\framebreak

\begin{code}
  minus-e  : ∀{e₁ e₂}{v₁ v₂}

          → E ⊢ e₁ ⇓ₐ v₁
          → E ⊢ e₂ ⇓ₐ v₂
            ---------------------
          → E ⊢ e₁ - e₂ ⇓ₐ minus v₁ v₂

  times-e : ∀{e₁ e₂}{v₁ v₂}

          → E ⊢ e₁ ⇓ₐ v₁
          → E ⊢ e₂ ⇓ₐ v₂
            ---------------------
          → E ⊢ e₁ × e₂ ⇓ₐ times v₁ v₂
\end{code}
\end{frame}

\begin{frame}
Semantics of boolean expressions of While\textsuperscript{int} are defined in RSD as follows:

The functional $\llbracket \cdot \rrbracket$ maps every $b \in Exp_{bool}$ to a function $\llbracket b \rrbracket : \Sigma \to \{ F, T \}$.

\includegraphics[width=\textwidth]{def53b.png}

\end{frame}

\begin{frame}[fragile,allowframebreaks]
\begin{code}
data _⊢_⇓₀_ {n : ℕ} ( E : Vec ℤ n) : Exp-bool n → Bool → Set where
  true-e   :

            -------------
            E ⊢ ⊤ ⇓₀ true

  false-e   :

            -------------
            E ⊢ ⊥ ⇓₀ false

  not-e : ∀{e}{v}

          → E ⊢ e ⇓₀ v
            ---------------------
          → E ⊢ ¬ e ⇓₀ not v
\end{code}

\framebreak

\begin{code}
  and-e  : ∀{e₁ e₂}{v₁ v₂}

          → E ⊢ e₁ ⇓₀ v₁
          → E ⊢ e₂ ⇓₀ v₂
            ---------------------
          → E ⊢ e₁ ∧ e₂ ⇓₀ and v₁ v₂

  or-e  : ∀{e₁ e₂}{v₁ v₂}

          → E ⊢ e₁ ⇓₀ v₁
          → E ⊢ e₂ ⇓₀ v₂
            ---------------------
          → E ⊢ e₁ ∨ e₂ ⇓₀ or v₁ v₂
\end{code}

\framebreak

\begin{code}
  equals-e  : ∀{e₁ e₂}{v₁ v₂}

          → E ⊢ e₁ ⇓ₐ v₁
          → E ⊢ e₂ ⇓ₐ v₂
            ---------------------
          → E ⊢ e₁ ≡ e₂ ⇓₀ ⌊ v₁ ≟ v₂ ⌋

  nequals-e  : ∀{e₁ e₂}{v₁ v₂}

          → E ⊢ e₁ ⇓ₐ v₁
          → E ⊢ e₂ ⇓ₐ v₂
            ---------------------
          → E ⊢ e₁ ≡ e₂ ⇓₀ not ⌊ v₁ ≟ v₂ ⌋
\end{code}

\framebreak

\begin{code}
  less-e  : ∀{e₁ e₂}{v₁ v₂}

          → E ⊢ e₁ ⇓ₐ v₁
          → E ⊢ e₂ ⇓ₐ v₂
            ---------------------
          → E ⊢ e₁ < e₂ ⇓₀ and (⌊ v₁ ≤? v₂ ⌋) (not ⌊ v₁ ≟ v₂ ⌋)

  leq-e  : ∀{e₁ e₂}{v₁ v₂}

          → E ⊢ e₁ ⇓ₐ v₁
          → E ⊢ e₂ ⇓ₐ v₂
            ---------------------
          → E ⊢ e₁ ≤ e₂ ⇓₀ ⌊ v₁ ≤? v₂ ⌋
\end{code}

\framebreak

\begin{code}
  greater-e  : ∀{e₁ e₂}{v₁ v₂}

          → E ⊢ e₁ ⇓ₐ v₁
          → E ⊢ e₂ ⇓ₐ v₂
            ---------------------
          → E ⊢ e₁ > e₂ ⇓₀ not ⌊ v₁ ≤? v₂ ⌋

  geq-e  : ∀{e₁ e₂}{v₁ v₂}

          → E ⊢ e₁ ⇓ₐ v₁
          → E ⊢ e₂ ⇓ₐ v₂
            ---------------------
          → E ⊢ e₁ ≥ e₂ ⇓₀ or (not ⌊ v₁ ≤? v₂ ⌋) (⌊ v₁ ≟ v₂ ⌋)
\end{code}
\end{frame}

\begin{frame}
Semantics of commands of While\textsuperscript{int} are defined in RSD using a standard operational, natrual style semantics based on an evaluation relation:

\includegraphics[width=\textwidth]{fig52.png}

\end{frame}

\begin{frame}[fragile,allowframebreaks]
\begin{code}
data _⊢_⇓_ {n : ℕ} ( E : Vec ℤ n) : Comm n → (E : Vec ℤ n) → Set where
  skip-e : 
           -------------------
           E ⊢ skip ⇓ E

  seq-e  : ∀{c₁ c₂}{e₁ e₂}

          → E ⊢ c₁ ⇓ e₁
          → e₁ ⊢ c₂ ⇓ e₂
            ---------------------
          → E ⊢ c₁ , c₂ ⇓ e₂
\end{code}

\framebreak

\begin{code}
  assign-e  : ∀{a}{n}{x}

          → E ⊢ a ⇓ₐ n
            ---------------------
          → E ⊢ (x ≔ a) ⇓ (E [ x ]≔ n)
\end{code}

\framebreak

\begin{code}
  if-true-e  : ∀{b}{c₁ c₂}{e₁}

          → E ⊢ b ⇓₀ true
          → E ⊢ c₁ ⇓ e₁
            ---------------------
          → E ⊢ if b then c₁ else c₂ ⇓ e₁

  if-false-e  : ∀{b}{c₁ c₂}{e₂}

          → E ⊢ b ⇓₀ false
          → E ⊢ c₂ ⇓ e₂
            ---------------------
          → E ⊢ if b then c₁ else c₂ ⇓ e₂
\end{code}

\framebreak

\begin{code}
  while-true-e  : ∀{b}{c}{E′ E″}

          → E ⊢ b ⇓₀ true
          → E ⊢ c ⇓ E′
          → E′ ⊢ while b do c ⇓ E″
            ---------------------
          → E ⊢ while b do c ⇓ E″

  while-false-e  : ∀{b}{c}

          → E ⊢ b ⇓₀ false
            ---------------------
          → E ⊢ while b do c ⇓ E
\end{code}
\end{frame}
\end{document}

