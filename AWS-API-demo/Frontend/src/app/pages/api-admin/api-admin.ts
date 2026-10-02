import { ApiService, ApiResponse } from '../../services/api';
import { Component, inject, OnInit, ChangeDetectorRef } from '@angular/core';
import { JsonPipe } from '@angular/common';

@Component({
  selector: 'app-api-admin',
  standalone: true,
  imports: [JsonPipe],
  templateUrl: './api-admin.html',
  styleUrl: './api-admin.css'
})
export class ApiAdmin implements OnInit {
  private readonly apiService = inject(ApiService);
  private readonly cdr = inject(ChangeDetectorRef);

  response: ApiResponse | null = null;
  loading = false;
  error = '';

  ngOnInit(): void {
    this.callApi();
  }

  callApi(): void {
    this.loading = true;
    this.response = null;
    this.error = '';

    this.apiService.callApi('admin').subscribe({
      next: (response) => {
        this.response = response;
        this.loading = false;
        this.cdr.markForCheck(); // Explicitly notify Angular to re-render
      },
      error: (error) => {
        console.error('API request failed:', error);
        this.error = error.error?.message || 'The API request failed.';
        this.loading = false;
        this.cdr.markForCheck();
      }
    });
  }
}