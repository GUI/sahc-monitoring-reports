import Rollbar from 'rollbar';

const enabled = import.meta.env.MODE === 'production';

const rollbar = new Rollbar({
  accessToken: import.meta.env.VITE_ROLLBAR_ACCESS_TOKEN,
  captureUncaught: enabled,
  captureUnhandledRejections: enabled,
  payload: {
    environment: import.meta.env.MODE,
  },
});

export default rollbar;
