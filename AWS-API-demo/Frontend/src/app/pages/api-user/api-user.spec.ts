import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ApiUser } from './api-user';

describe('ApiUser', () => {
  let component: ApiUser;
  let fixture: ComponentFixture<ApiUser>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ApiUser],
    }).compileComponents();

    fixture = TestBed.createComponent(ApiUser);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
