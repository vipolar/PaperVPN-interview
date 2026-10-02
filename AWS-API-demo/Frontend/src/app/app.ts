import { RouterOutlet, RouterLinkActive, RouterLink } from '@angular/router';
import { OidcSecurityService, LoginResponse } from 'angular-auth-oidc-client';
import { Component, signal, OnInit, inject } from '@angular/core';

@Component({
  imports: [
    RouterLink,
    RouterLinkActive,
    RouterOutlet
  ],
  standalone: true,
  selector: 'app-root',
  styleUrl: './app.css',
  templateUrl: './app.html',
})
export class App implements OnInit {
  private readonly oidcSecurityService = inject(OidcSecurityService);
  protected readonly title = signal('Frontend');

  isAuthenticated = false;

  ngOnInit(): void {
    this.oidcSecurityService.checkAuth().subscribe({
      next: (result: LoginResponse) => {
        this.isAuthenticated = result.isAuthenticated;
        console.log('Authenticated:', result.isAuthenticated);
      },
      error: (error) => {
        console.error('Authentication check failed:', error);
      }
    });
  }

  login(): void {
    this.oidcSecurityService.authorize();
  }

  logout(): void {
    this.oidcSecurityService.logoffLocal();

    const cognitoDomain = import.meta.env['NG_APP_COGNITO_DOMAIN'];
    const logoutUri = import.meta.env['NG_APP_COGNITO_LOGOUT_URL'];
    const clientId = import.meta.env['NG_APP_COGNITO_CLIENT_ID'];

    const logoutUrl =
      `${cognitoDomain}/logout` +
      `?client_id=${encodeURIComponent(clientId)}` +
      `&logout_uri=${encodeURIComponent(logoutUri)}`;

    window.location.assign(logoutUrl);
  }
}

