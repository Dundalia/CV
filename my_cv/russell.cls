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
\RequirePackage{fontawesome5}
\RequirePackage{hyperref}

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
\newcommand*{\fontdir}[1][fonts/]{\def\@fontdir{#1}}
\newcommand{\acvHeaderSocialSep}{\quad\textbar\quad}

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
\newcommand*{\mobile}[1]{\def\@mobile{#1}}
\newcommand*{\position}[1]{\def\@position{#1}}
\newcommand*{\address}[1]{\def\@address{#1}}

%-------------------------------------------------------------------------------
%                Header and footer
%-------------------------------------------------------------------------------
\newcommand*{\makecvheader}[1][C]{%
  \begin{center}
    {\fontsize{24pt}{1em}\bfseries\@firstname~\@lastname}
    
    \vspace{3mm}
    
    {\small%
      \ifx\@email\undefined\else\faEnvelope~\href{mailto:\@email}{\@email}\fi%
      \ifx\@homepage\undefined\else\acvHeaderSocialSep\faHome~\href{http://\@homepage}{\@homepage}\fi%
      \ifx\@github\undefined\else\acvHeaderSocialSep\faGithub~\href{https://\@github}{github}\fi%
      \ifx\@linkedin\undefined\else\acvHeaderSocialSep\faLinkedin~\href{https://www.\@linkedin}{linkedin}\fi%
    }
  \end{center}
  \vspace{5mm}
}

\newcommand*{\makecvfooter}[3]{%
  \fancyfoot[L]{{\small\scshape #1}}
  \fancyfoot[C]{{\small\scshape #2}}
  \fancyfoot[R]{{\small\scshape #3}}
}

%-------------------------------------------------------------------------------
%                Section command
%-------------------------------------------------------------------------------
\newcommand{\cvsection}[1]{%
  \vspace{2mm}
  \noindent{\Large\scshape\bfseries\@sectioncolor #1}
  \par\nobreak
  \vspace{-3.0mm}
  \noindent{\color{graytext}\hrule height 0.5pt}
  \vspace{1.5mm}
}

\newcommand{\cvsubsection}[1]{%
  \vspace{1.5mm}
  {\noindent\large\scshape #1}
  \vspace{.5mm}
  \par\nobreak
  \vspace{1.5mm}
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
  \begin{tabular*}{\textwidth}{@{}p{0.7\textwidth}@{\extracolsep{\fill}}r@{}}
    \textbf{#2} & \textit{#3} \\
    #1 & \textit{#4}
  \end{tabular*}
  \par\vspace{0.5mm}
  \noindent#5
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
  \begin{tabular*}{\textwidth}{@{}p{0.2\textwidth}p{0.78\textwidth}@{}}
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
  \begin{tabular*}{\textwidth}{@{}p{0.12\textwidth}p{0.60\textwidth}@{\extracolsep{\fill}}r@{}}
}{%
  \end{tabular*}
  \par\vspace{2mm}
}

\newcommand*{\cvhonor}[4]{%
  \textit{#4} & \textbf{#1}, #2 & \textit{#3} \\[3pt]
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

