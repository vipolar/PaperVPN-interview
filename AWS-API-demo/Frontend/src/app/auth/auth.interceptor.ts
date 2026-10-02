import { HttpInterceptorFn } from '@angular/common/http';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { inject } from '@angular/core';
import { switchMap } from 'rxjs';

const API_URL = import.meta.env['NG_APP_API_URL'];

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  if (!req.url.startsWith(API_URL)) {
    return next(req);
  }

  const oidcSecurityService = inject(OidcSecurityService);
  return oidcSecurityService.getAccessToken().pipe(
    switchMap((accessToken) => {
      if (!accessToken) {
        return next(req);
      }

      const authenticatedRequest = req.clone({
        setHeaders: {
          Authorization: `Bearer ${accessToken}`
        }
      });

      return next(authenticatedRequest);
    })
  );
};
