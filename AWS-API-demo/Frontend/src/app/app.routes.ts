import { ApiAdmin } from './pages/api-admin/api-admin';
import { ApiGuest } from './pages/api-guest/api-guest';
import { ApiUser } from './pages/api-user/api-user';
import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    component: ApiGuest,
    pathMatch: 'full',
  },
  {
    path: 'api-user',
    component: ApiUser
  },
  {
    path: 'api-admin',
    component: ApiAdmin
  },
  {
    path: '**',
    redirectTo: ''
  }
];
