#!/usr/bin/env python3
"""
Generate a clean Markdown version of the CV from LaTeX source files.
"""

import re
from pathlib import Path
from datetime import datetime


def clean_latex(text: str) -> str:
    """Remove/convert LaTeX commands to Markdown equivalents."""
    # Handle paper resource links: \cvextlink{url}{[code]} -> [code](url)
    text = re.sub(r'\\cvextlink\{([^}]+)\}\{\[?([^}\]]+)\]?\}', r'[\2](\1)', text)

    # Handle inline math used in the CV
    text = text.replace('$^*$', '\\*')
    text = text.replace(r'$\sim$', '~')
    text = text.replace(r'$\phi$', 'φ')
    text = text.replace(r'\quad', ' ')

    # Handle href with textbf inside: \href{url}{\textbf{text}} -> [**text**](url)
    text = re.sub(r'\\href\{([^}]+)\}\{\\textbf\{([^}]+)\}\}', r'[**\2**](\1)', text)
    
    # Handle href links: \href{url}{text} -> [text](url)
    text = re.sub(r'\\href\{([^}]+)\}\{([^}]+)\}', r'[\2](\1)', text)
    
    # Handle textbf: \textbf{text} -> **text**
    text = re.sub(r'\\textbf\{([^}]+)\}', r'**\1**', text)
    
    # Handle textit: \textit{text} -> *text*
    text = re.sub(r'\\textit\{([^}]+)\}', r'*\1*', text)
    
    # Handle LaTeX symbol
    text = text.replace(r'\LaTeX', 'LaTeX')
    
    # Handle special characters
    text = text.replace(r'\%', '%')
    text = text.replace(r'\&', '&')
    text = text.replace(r'\_', '_')
    text = text.replace(r'\$', '$')
    text = text.replace(r'\#', '#')
    text = text.replace(r'\newline', ' ')
    
    # Handle quotes
    text = text.replace("``", '"')
    text = text.replace("''", '"')
    
    # Remove remaining simple LaTeX commands
    text = re.sub(r'\\[a-zA-Z]+\{([^}]*)\}', r'\1', text)
    
    # Clean up extra whitespace
    text = re.sub(r'\s+', ' ', text).strip()
    
    return text


def extract_brace_content(text: str, start_pos: int) -> tuple:
    """Extract content within braces, handling nested braces."""
    if start_pos >= len(text) or text[start_pos] != '{':
        return '', start_pos
    
    depth = 0
    content_start = start_pos + 1
    pos = start_pos
    
    while pos < len(text):
        if text[pos] == '{':
            depth += 1
        elif text[pos] == '}':
            depth -= 1
            if depth == 0:
                return text[content_start:pos], pos + 1
        pos += 1
    
    return text[content_start:], pos


def parse_cventry(content: str) -> list:
    """Parse cventry blocks from LaTeX content."""
    entries = []
    
    # Find all \cventry occurrences
    pattern = r'\\cventry\s*'
    for match in re.finditer(pattern, content):
        pos = match.end()
        
        # Extract 5 brace arguments
        args = []
        for _ in range(5):
            # Skip whitespace and comments
            while pos < len(content):
                if content[pos] in ' \t\n':
                    pos += 1
                elif content[pos] == '%':
                    # Skip to end of line
                    while pos < len(content) and content[pos] != '\n':
                        pos += 1
                    if pos < len(content):
                        pos += 1  # Skip the newline
                else:
                    break
            if pos < len(content) and content[pos] == '{':
                arg, pos = extract_brace_content(content, pos)
                args.append(arg)
            else:
                break
        
        if len(args) == 5:
            title = clean_latex(args[0])
            organization = clean_latex(args[1])
            location = clean_latex(args[2])
            dates = clean_latex(args[3])
            description_block = args[4]
            
            # Parse cvitems - handle nested braces properly
            items = []
            item_pattern = r'\\item\s*\{'
            for item_match in re.finditer(item_pattern, description_block):
                # Check if this \item is on a commented line
                line_start = description_block.rfind('\n', 0, item_match.start())
                if line_start == -1:
                    line_start = 0
                else:
                    line_start += 1
                line_prefix = description_block[line_start:item_match.start()].strip()
                if line_prefix.startswith('%'):
                    continue
                    
                item_content, _ = extract_brace_content(description_block, item_match.end() - 1)
                # Skip if this looks like a commented line
                if item_content.strip().startswith('%'):
                    continue
                item_text = clean_latex(item_content)
                if item_text:
                    items.append(item_text)
            
            entries.append({
                'title': title,
                'organization': organization,
                'location': location,
                'dates': dates,
                'items': items
            })
    
    return entries


def parse_cvpublication(content: str) -> list:
    """Parse cvpublication blocks from LaTeX content."""
    publications = []
    pattern = r'\\cvpublication\s*'

    for match in re.finditer(pattern, content):
        pos = match.end()

        # Optional [links] argument; brackets inside braces (e.g. {[code]}) don't close it
        links = ''
        if pos < len(content) and content[pos] == '[':
            depth = 0
            end = pos + 1
            while end < len(content) and not (content[end] == ']' and depth == 0):
                depth += {'{': 1, '}': -1}.get(content[end], 0)
                end += 1
            links = clean_latex(content[pos + 1:end])
            pos = end + 1

        # Extract 3 brace arguments: title, authors, venue
        args = []
        for _ in range(3):
            while pos < len(content) and content[pos] in ' \t\n':
                pos += 1
            if pos < len(content) and content[pos] == '{':
                arg, pos = extract_brace_content(content, pos)
                args.append(arg)
            else:
                break

        if len(args) == 3:
            title = clean_latex(args[0]).replace('{', '').replace('}', '')
            venue = re.sub(r'\\begin\{tabular\}(\[[^\]]*\])?\{@\{\}r@\{\}\}|\\end\{tabular\}', '', args[2])
            venue = '; '.join(clean_latex(v) for v in venue.split('\\\\'))
            publications.append({
                'title': title,
                'links': links,
                'authors': clean_latex(args[1]),
                'venue': venue
            })

    return publications


def parse_cvhonor(content: str) -> list:
    """Parse cvhonor blocks from LaTeX content."""
    honors = []
    pattern = r'\\cvhonor\s*'
    
    for match in re.finditer(pattern, content):
        pos = match.end()
        
        # Extract 4 brace arguments
        args = []
        for _ in range(4):
            # Skip whitespace and comments
            while pos < len(content):
                if content[pos] in ' \t\n':
                    pos += 1
                elif content[pos] == '%':
                    while pos < len(content) and content[pos] != '\n':
                        pos += 1
                    if pos < len(content):
                        pos += 1
                else:
                    break
            if pos < len(content) and content[pos] == '{':
                arg, pos = extract_brace_content(content, pos)
                args.append(arg)
            else:
                break
        
        if len(args) == 4:
            award = clean_latex(args[0])
            event = clean_latex(args[1])
            location = clean_latex(args[2])
            date = clean_latex(args[3])
            
            honors.append({
                'award': award,
                'event': event,
                'location': location,
                'date': date
            })
    
    return honors


def parse_cvskill(content: str) -> list:
    """Parse cvskill blocks from LaTeX content."""
    skills = []
    pattern = r'\\cvskill\s*'
    
    for match in re.finditer(pattern, content):
        pos = match.end()
        
        # Extract 2 brace arguments
        args = []
        for _ in range(2):
            # Skip whitespace and comments
            while pos < len(content):
                if content[pos] in ' \t\n':
                    pos += 1
                elif content[pos] == '%':
                    while pos < len(content) and content[pos] != '\n':
                        pos += 1
                    if pos < len(content):
                        pos += 1
                else:
                    break
            if pos < len(content) and content[pos] == '{':
                arg, pos = extract_brace_content(content, pos)
                args.append(arg)
            else:
                break
        
        if len(args) == 2:
            category = clean_latex(args[0])
            skill_list = clean_latex(args[1])
            skills.append({
                'category': category,
                'skills': skill_list
            })
    
    return skills


def generate_markdown():
    """Generate the complete Markdown CV."""
    cv_dir = Path(__file__).parent / 'cv'
    
    md = []
    
    # Header
    md.append("# DAVIDE BALDELLI")
    md.append("")
    md.append("**PhD researcher at Polytechnique Montréal and Mila**")
    md.append("")
    md.append("[davide.baldelli@mila.quebec](mailto:davide.baldelli@mila.quebec) • [dundalia.github.io](https://dundalia.github.io) • [LinkedIn](https://linkedin.com/in/davide-baldelli-b55618203/) • [GitHub](https://github.com/Dundalia) • [Google Scholar](https://scholar.google.com/citations?user=PTOykNQAAAAJ&hl=it)")
    md.append("")
    md.append("---")
    md.append("")
    
    # Education
    md.append("## 🎓 Education")
    md.append("")
    education_content = (cv_dir / 'education.tex').read_text()
    # Remove commented blocks
    education_content = re.sub(r'\\begin\{comment\}.*?\\end\{comment\}', '', education_content, flags=re.DOTALL)
    entries = parse_cventry(education_content)
    for entry in entries:
        md.append(f"### {entry['title']}")
        md.append(f"**{entry['organization']}** | *{entry['dates']}*")
        md.append("")
        for item in entry['items']:
            md.append(f"- {item}")
        md.append("")

    # Publications
    md.append("## 📄 Publications")
    md.append("")
    publications_content = (cv_dir / 'publications.tex').read_text()
    for pub in parse_cvpublication(publications_content):
        md.append(f"- **{pub['title']}**")
        if pub['links']:
            md.append(f"  - {pub['authors']} · {pub['links']}")
        else:
            md.append(f"  - {pub['authors']}")
        md.append(f"  - *{pub['venue']}*")
        md.append("")
    if '$^*$' in publications_content:
        md.append("\\* Equal contribution.")
        md.append("")

    # Experience
    md.append("## Experience")
    md.append("")
    positions_content = (cv_dir / 'positions.tex').read_text()
    entries = parse_cventry(positions_content)
    for entry in entries:
        md.append(f"### {entry['title']}")
        md.append(f"**{entry['organization']}** | *{entry['dates']}*")
        md.append("")
        for item in entry['items']:
            md.append(f"- {item}")
        md.append("")
    
    # Service and Leadership
    md.append("## 🤝 Service and Leadership")
    md.append("")
    misc_content = (cv_dir / 'miscellaneous.tex').read_text()
    entries = parse_cventry(misc_content)
    for entry in entries:
        md.append(f"### {entry['title']}")
        md.append(f"**{entry['organization']}** | *{entry['dates']}*")
        md.append("")
        for item in entry['items']:
            md.append(f"- {item}")
        md.append("")
    
    # Additional Information
    md.append("## Additional Information")
    md.append("")
    additional_content = (cv_dir / 'additional.tex').read_text()
    additional = parse_cvskill(additional_content)
    for item in additional:
        md.append(f"- **{item['category']}:** {item['skills']}")
    md.append("")

    generated_on = datetime.now().strftime('%B %-d, %Y')
    md.append(f"*Generated on {generated_on}. For the latest version, see [dundalia.github.io/CV/cv.pdf](https://dundalia.github.io/CV/cv.pdf).*")
    
    return '\n'.join(md)


if __name__ == '__main__':
    output_path = Path(__file__).parent / 'resume.md'
    markdown_content = generate_markdown()
    output_path.write_text(markdown_content)
    print(f"✓ Generated {output_path}")
