%-------------------------------------------------------------------------------
%                Identification
%-------------------------------------------------------------------------------
\ProvidesClass{russell}[2025/01/06 v2.0.0 Minimal Russell CV Class]
\NeedsTeXFormat{LaTeX2e}

%-------------------------------------------------------------------------------
%                Class options
%-------------------------------------------------------------------------------
\DeclareOption{draft}{\setlength\overfullrule{5pt}}
\DeclareOption{final}{\setlength\overfullrule{0pt}}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass{article}

%-------------------------------------------------------------------------------
%                Required packages
%-------------------------------------------------------------------------------
\RequirePackage{geometry}
\RequirePackage{fancyhdr}
\RequirePackage{xcolor}
\RequirePackage{etoolbox}
\RequirePackage{enumitem}
\RequirePackage{verbatim}  % For comment environment
\RequirePackage{graphicx}  % For \includegraphics
\RequirePackage{array}
\RequirePackage{fontawesome5}
\RequirePackage{hyperref}
\RequirePackage{ulem}
\RequirePackage{fontspec}

% Hyperref configuration - underlined links without boxes
\hypersetup{
    colorlinks=true,
    linkcolor=black,
    urlcolor=black,
    citecolor=black,
    pdfborder={0 0 0},
}

% Make all URLs underlined
\let\oldhref\href
\renewcommand{\href}[2]{\oldhref{#1}{\uline{#2}}}

\defaultfontfeatures{Ligatures=TeX}

% Bibliography
\RequirePackage[
    sorting=ydnt,
    style=authoryear,
    dashed=false,
    maxcitenames=99,
    maxbibnames=99,
    hyperref=true,
    backend=biber
]{biblatex}

%-------------------------------------------------------------------------------
%                Layout configuration
%-------------------------------------------------------------------------------
\geometry{left=2.0cm, top=1.5cm, right=2.0cm, bottom=2.0cm, footskip=.5cm}
\pagestyle{fancy}
\fancyhf{}
\renewcommand{\headrulewidth}{0pt}

%-------------------------------------------------------------------------------
%                Colors
%-------------------------------------------------------------------------------
\definecolor{darktext}{HTML}{333333}
\definecolor{graytext}{HTML}{5D5D5D}
\definecolor{lighttext}{HTML}{999999}
\colorlet{text}{darktext}

% russell color (customizable)
\definecolor{russell-emerald}{HTML}{00A388}
\definecolor{russell-skyblue}{HTML}{0395DE}
\definecolor{russell-red}{HTML}{DC3522}
\colorlet{russell}{russell-red}

% Boolean for section color highlighting
\newbool{acvSectionColorHighlight}
\setbool{acvSectionColorHighlight}{true}

%-------------------------------------------------------------------------------
%                Helper commands
%-------------------------------------------------------------------------------
\newcommand*{\fontdir}[1][fonts/]{%
  \def\@fontdir{#1}%
  \setmainfont{et-book}[
    Path=\@fontdir/et-book/,
    UprightFont=et-book-roman-line-figures.ttf,
    BoldFont=et-book-bold-line-figures.ttf,
    ItalicFont=et-book-display-italic-old-style-figures.ttf,
    BoldItalicFont=et-book-display-italic-old-style-figures.ttf
  ]%
}
\newcommand*{\googlescholaricon}{\raisebox{-0.15ex}{\includegraphics[height=1.05em]{images/icons/google-scholar.png}}}
\newcommand{\acvHeaderSocialSep}{\quad}

% Section color helper
\def\@sectioncolor#1#2#3{%
  \ifbool{acvSectionColorHighlight}{{\color{russell}#1#2#3}}{#1#2#3}%
}

%-------------------------------------------------------------------------------
%                Personal information commands
%-------------------------------------------------------------------------------
\newcommand*{\name}[2]{\def\@firstname{#1}\def\@lastname{#2}}
\newcommand*{\email}[1]{\def\@email{#1}}
\newcommand*{\homepage}[1]{\def\@homepage{#1}}
\newcommand*{\github}[1]{\def\@github{#1}}
\newcommand*{\linkedin}[1]{\def\@linkedin{#1}}
\newcommand*{\googlescholar}[1]{\def\@googlescholar{#1}}
\newcommand*{\mobile}[1]{\def\@mobile{#1}}
\newcommand*{\position}[1]{\def\@position{#1}}
\newcommand*{\address}[1]{\def\@address{#1}}

%-------------------------------------------------------------------------------
%                Header and footer
%-------------------------------------------------------------------------------
\newcommand*{\makecvheader}[1][C]{%
  \def\@headeralign{#1}%
  \begin{center}
  {\fontsize{24pt}{1em}\bfseries\MakeUppercase{\@firstname~\@lastname}\par}
  \ifx\@position\undefined\else
    \vspace{2.0mm}
    {\fontsize{12pt}{1em}\selectfont\@position\par}
  \fi
  \vspace{1.5mm}
  
  {\footnotesize%
    \ifx\@email\undefined\else\faEnvelope~\oldhref{mailto:\@email}{\@email}\fi%
    \ifx\@homepage\undefined\else\acvHeaderSocialSep\faGlobe~\oldhref{http://\@homepage}{\@homepage}\fi%
    \ifx\@github\undefined\else\acvHeaderSocialSep\faGithub~\oldhref{https://\@github}{github}\fi%
    \ifx\@linkedin\undefined\else\acvHeaderSocialSep\faLinkedin~\oldhref{https://www.\@linkedin}{linkedin}\fi%
    \ifx\@googlescholar\undefined\else\acvHeaderSocialSep\googlescholaricon~\oldhref{\@googlescholar}{scholar}\fi%
  }
  \par
  \end{center}
  \vspace{3mm}
}

\newcommand*{\makecvfooter}[3]{%
  \fancyfoot[L]{{\small #1}}
  \fancyfoot[C]{{\small #2}}
  \fancyfoot[R]{{\small #3}}
}

%-------------------------------------------------------------------------------
%                Section command
%-------------------------------------------------------------------------------
\newcommand{\cvsection}[1]{%
  \vspace{2.8mm}
  \noindent{\Large\bfseries\ifbool{acvSectionColorHighlight}{{\color{russell}\MakeUppercase{#1}}}{\MakeUppercase{#1}}}
  \par\nobreak
  \vspace{-3.0mm}
  \noindent{\color{graytext}\hrule height 0.5pt}
  \vspace{2.5mm}
}

\newcommand{\cvsubsection}[1]{%
  \vspace{1mm}
  {\noindent\large\bfseries #1}
  \vspace{.5mm}
  \par\nobreak
  \vspace{1.5mm}
}

%-------------------------------------------------------------------------------
%                Publications
%-------------------------------------------------------------------------------
\newenvironment{cvpublications}{%
  \par\vspace{1mm}
}{%
  \par\vspace{1mm}
}

\newcommand*{\cvpublink}[1]{%
  \oldhref{#1}{\textcolor{russell-skyblue}{\faLink}}%
}

\newlength{\cvpubiconwidth}
\setlength{\cvpubiconwidth}{1.4em}

\newcommand*{\cvpublication}[4][]{%
  \noindent
  \begin{minipage}[t]{\textwidth}
    \noindent
    \begin{tabular*}{\textwidth}{@{}p{\cvpubiconwidth}@{}p{0.68\textwidth}@{\extracolsep{\fill}}r@{}}
      #1 & \raggedright\textbf{#2} & {\footnotesize\itshape #4} \\
      & \multicolumn{2}{@{}p{\dimexpr\textwidth-\cvpubiconwidth\relax}@{}}{{\footnotesize #3}}
    \end{tabular*}
  \end{minipage}
  \par\vspace{1.2mm}
}

%-------------------------------------------------------------------------------
%                CV Entry (cventry)
%-------------------------------------------------------------------------------
% Usage: \cventry{position}{title}{location}{date}{description}
\newenvironment{cventries}{%
  % No extra space - handled by \cvsection
}{%
  \par\vspace{2mm}
}

\newcommand*{\cventry}[5]{%
  \vspace{1mm}
  \noindent
  \ifstrempty{#1}{%
    \begin{tabular*}{\textwidth}{@{}p{0.74\textwidth}@{\extracolsep{\fill}}r@{}}
      \textbf{#2} & \textit{#4}
    \end{tabular*}
  }{%
    \begin{tabular*}{\textwidth}{@{}p{0.74\textwidth}@{\extracolsep{\fill}}r@{}}
      \textbf{#2} & \textit{#4} \\
      #1 &
    \end{tabular*}
  }%
  \ifstrempty{#5}{}{%
    \par\vspace{0.5mm}
    \noindent#5
  }%
  \par\vspace{1mm}
}

% Compact entry for sections that have no separate role/degree line.
\newcommand*{\cvpositionentry}[4]{%
  \vspace{1mm}
  \noindent
  \begin{tabular*}{\textwidth}{@{}p{0.74\textwidth}@{\extracolsep{\fill}}r@{}}
    \textbf{#1} & \textit{#3}
  \end{tabular*}
  \ifstrempty{#4}{}{%
    \par\vspace{-0.5mm}
    \noindent#4%
  }%
  \par\vspace{1mm}
}

%-------------------------------------------------------------------------------
%                CV Items (bullet points)
%-------------------------------------------------------------------------------
\newenvironment{cvitems}{%
  \begin{itemize}[leftmargin=*, nosep, noitemsep, label=\textbullet]
}{%
  \end{itemize}
}

%-------------------------------------------------------------------------------
%                CV Skills
%-------------------------------------------------------------------------------
\newenvironment{cvskills}{%
  % No extra space - handled by \cvsection
  \noindent
  \begin{tabular*}{\textwidth}{@{}p{0.18\textwidth}@{\hspace{0.02\textwidth}}>{\raggedright\arraybackslash}p{0.78\textwidth}@{}}
}{%
  \end{tabular*}
  \par\vspace{2mm}
}

\newcommand*{\cvskill}[2]{%
  \textbf{#1} & #2 \\[3pt]
}

%-------------------------------------------------------------------------------
%                CV Honors/Awards
%-------------------------------------------------------------------------------
\newenvironment{cvhonors}{%
  % No extra space - handled by \cvsection
  \noindent
  \begin{tabular*}{\textwidth}{@{}p{0.74\textwidth}@{\extracolsep{\fill}}r@{}}
}{%
  \end{tabular*}
  \par\vspace{2mm}
}

\newcommand*{\cvhonor}[4]{%
  \textbf{#1}, #2 & \textit{#4} \\[3pt]
}

%-------------------------------------------------------------------------------
%                Bibliography formatting
%-------------------------------------------------------------------------------
\renewcommand*{\bibfont}{\small}
\setlength\bibitemsep{0.5\baselineskip}

% Remove extra space before bibliography lists
\AtBeginBibliography{\vspace{-3mm}}

% APA-like formatting
\renewbibmacro{in:}{}

%-------------------------------------------------------------------------------
\endinput
