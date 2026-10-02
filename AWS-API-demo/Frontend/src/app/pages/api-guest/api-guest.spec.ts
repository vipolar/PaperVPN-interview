import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ApiGuest } from './api-guest';

describe('ApiGuest', () => {
  let component: ApiGuest;
  let fixture: ComponentFixture<ApiGuest>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ApiGuest],
    }).compileComponents();

    fixture = TestBed.createComponent(ApiGuest);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
