from .base import Base
from denite import util


class Kind(Base):
    def __init__(self, vim):
        super().__init__(vim)

        self.name = 'session'
        self.default_action = 'switch'

    def action_switch(self, context):
        target = context['targets'][0]
        command = 'Prosession ' + target['session']
        output = self.vim.call(
            'denite#util#execute_command', command, False
        )

        output and self.debug(output)
