// Even more jank replacement for the already jank yauzl replacement by just using 7z where the jank replacement was using unzip where it expects and skipping (speed++, size--, jank++++)
const { execFile } = require('child_process');
const mkdirp = require('mkdirp');

exports.open = async (zipPath, _opts, callback) => {
  const extractPath = `${global.moduleDataPath}/${zipPath.split('/').pop().split('.')[0].split('-')[0]}`;
  const listeners = [];

  const errorOut = (err) => {
    listeners.error(err);
  };

  const entryCount = await new Promise((res) => {
    execFile('7z', ['l', zipPath]).stdout.on('data', (x) => {
      const m = x.toString().match(/([0-9]+) files/);
      if (m) res(parseInt(m[1]));
    });

    setTimeout(res, 500);
  });

  callback(null, {
    on: (event, listener) => {
      listeners[event] = listener;
    },

    entryCount
  });

  mkdirp.sync(extractPath);

  const proc = execFile('7z', ['e', '-aoa', '-o' + extractPath, zipPath]);

  proc.on('error', (err) => {
    if (err.code === 'ENOENT') {
      require('electron').dialog.showErrorBox('Failed Dependency', 'Please install "7z", exiting');
      process.exit(1); // Close now
    }

    errorOut(err);
  });

  proc.stderr.on('data', errorOut);

  proc.stdout.on('data', (x) => x.toString().split('\n').forEach((x) => x.includes('inflating') && listeners.entry()));

  proc.on('close', () => listeners.end());
};
