import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ApiAdmin } from './api-admin';

describe('ApiAdmin', () => {
  let component: ApiAdmin;
  let fixture: ComponentFixture<ApiAdmin>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ApiAdmin],
    }).compileComponents();

    fixture = TestBed.createComponent(ApiAdmin);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
