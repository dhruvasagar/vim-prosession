import re
from .base import Base


def format_split(match, ctx):
    """ Splits the match so the last part of the path is
        shown at the left part of the screen.
    """
    width = int(ctx.get('winwidth'))
    parts = re.split(r'/(?=.)', match)
    last = parts[-1].replace('/', '')
    rest = '/'.join(parts[0:-1]) + '/'
    sep = ' ' * (width - len(rest+last))

    return last + sep + rest


def format_default(match, ctx):
    """ Does nothing
    """
    return match


def format_minimal(match, ctx):
    return re.split(r'/(?=.)', match)[-1]


FORMATTERS = {
    'default': format_default,
    'split': format_split,
    'minimal': format_minimal,
}

HIGHLIGHTERS = {
    'default': [
        {'name': 'File', 'link': 'Comment', 're': r'\/.*\/\(.\)\@='},
    ],
    'split': [
        {'name': 'File', 'link': 'Comment', 're': r' \/.*'},
    ],
    'minimal': [],
}


class Source(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'prosession'
        self.kind = 'session'
        self.vars = {
            'format': 'default'
        }

    def on_init(self, context):
        formatter = False

        if self.vars['format']:
            formatter = self.vars['format']
            if formatter not in FORMATTERS:
                self.error_message(context, 'Invalid format ' + formatter)
                formatter = False

        formatter = formatter or 'default'
        context['format'] = formatter

        self.syntax = HIGHLIGHTERS[formatter]

    def gather_candidates(self, ctx):
        """ Populates the denite buffer with the available
            sessions.
        """
        sessions = self.vim.eval("prosession#ListSessions()")
        formatter = FORMATTERS[ctx.get('format')]
        completions = []

        for session in sessions:

            completions.append({
                'word': session,
                'abbr': formatter(session, ctx),
                'session': session
            })

        return completions

    def highlight(self):
        """ Defines simple syntax for the matches in the
            denite window to highlight the last part of the path.
        """

        for syn in self.syntax:
            self.vim.command(
                'syntax match {0}_{1} /{2}/ contained containedin={0}'.format(
                    self.syntax_name, syn['name'], syn['re']))
            self.vim.command(
                'highlight default link {0}_{1} {2}'.format(
                    self.syntax_name, syn['name'], syn['link']))
