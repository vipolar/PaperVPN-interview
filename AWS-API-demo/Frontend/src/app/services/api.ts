import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface ApiResponse {
  message?: string;
  [key: string]: unknown;
}

export type ApiRole = 'user' | 'guest' | 'admin';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private readonly http = inject(HttpClient);

  private readonly baseUrl = import.meta.env['NG_APP_API_URL'];

  callApi(role: ApiRole): Observable<ApiResponse> {
    return this.http.get<ApiResponse>(`${this.baseUrl}/${role}`);
  }
}