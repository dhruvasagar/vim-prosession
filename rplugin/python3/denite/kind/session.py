from .base import Base
from denite import util


class Kind(Base):
    def __init__(self, vim):
        super().__init__(vim)

        self.name = 'session'
        self.default_action = 'switch'

    def exec_command(self, command, context):
        target = context['targets'][0]
        target = target['session']
        command = command.format(target=target)
        output = self.vim.call(
            'denite#util#execute_command', command, False
        )

        output and self.debug(output)

    def action_switch(self, context):
        self.exec_command('Prosession {target}', context)

    def action_delete(self, context):
        self.exec_command('ProsessionDelete {target}', context)
