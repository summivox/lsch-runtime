require! {
  # promise
  'bluebird': Promise

  # process
  'cross-spawn-async': spawn

  # fs, path, ...
  'fs-extra': fs
  'isexe'

  # stream
  'mississippi': miss
  'isstream': {isReadable, isWritable, isDuplex}:isStream

  # util belt
  'simple-is': Is
}

# redirection operator
#   optr: '<', '>', '>>', '<&', '>&'
#   fd: FD? -- own fd / default according to optr
export class ShellRedir => (@optr, @fd) ~> @
OPTR_TO_FLAGS = '<': 'r', '>': 'w', '>>': 'a'
OPTR_TO_DIR = '<': 'i', '>': 'o', '>>': 'o', '<&': 'i', '>&': 'o'

export function Shell cmd, ...

  if false
    # TODO: built-in command
    ...
  else
    # external command

    args = [] # actual command-line arguments

    # io: [] of
    #   dir: either
    #     'i' -- own input from readable
    #     'o' -- own output from writable
    #   connect: [] of either
    #     {path, flags} -- arguments to `fs.open`
    #     {shell, fd}: switch target
    #       null => parent fd
    #       this => own fd
    #       instanceof ShellObj => fd of another process
    #     Stream -- to nodejs-compatible stream
    io = []

    # scan raw arguments
    i = 0; l = arguments.length; while i < l, i++
      arg = arguments[i]

      if arg instanceof ShellRedir
        {optr, fd} = arg
        # assert optr of OPTR_TO_DIR
        dir = OPTR_TO_DIR[optr]

        # consume next arg as redirection target
        target = arguments[i + 1]
        ++i
        conn = switch typeof target
        | \string
          if optr in ['<&' '>&']
            fd = parseInt target
            # assert Number.isInteger fd
            {shell: this, fd}
          else
            {path: target, flags: OPTR_TO_FLAGS[optr]}
        | \object => switch
          # TODO
          | isStream target => target

        switch optr
        | \<
          io[fd ? 0] ?= {}
            ..dir = \i
            ..parent = null
            ..[]file.push [target, 'r']
        | \>
          io[fd ? 1] ?= {}
            ..dir = \o
            ..parent = null
            ..[]file.push [target, 'w']
        | \>>
          io[fd ? 1] ?= {}
            ..dir = \o
            ..parent = null
            ..[]file.push [target, 'a']
        | \<&
          io[fd ? 0] ?= {}
            ..dir = \i
            ..parent = null
            ..[]file.push target
        | \>&
          io[fd ? 2] ?= {}
            ..dir = \i
            ..parent = null
            ..[]file.push target


  var resolve, reject
  p = new Promise (resolve_, reject_) !->
    resolve := resolve_
    reject := reject_
