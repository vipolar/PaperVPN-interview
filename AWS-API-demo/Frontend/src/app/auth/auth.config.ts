import { PassedInitialConfig } from 'angular-auth-oidc-client';

const authorityUri = import.meta.env['NG_APP_AUTHORITY_URL'];
const redurectUri = import.meta.env['NG_APP_COGNITO_CALLBACK_URL'];
const logoutUri = import.meta.env['NG_APP_COGNITO_LOGOUT_URL'];
const clientId = import.meta.env['NG_APP_COGNITO_CLIENT_ID'];

export const authConfig: PassedInitialConfig = {
  config: {
    authority: authorityUri,
    scope: 'api-demo/admin api-demo/user.read api-demo/user.write email openid',
    postLogoutRedirectUri: logoutUri,
    redirectUrl: redurectUri,
    clientId: clientId,
    responseType: 'code',
    silentRenew: true,
    useRefreshToken: true,
    renewTimeBeforeTokenExpiresInSeconds: 30,
  },
};
